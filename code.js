const htmlparser = require('htmlparser2');
const fs = require('fs');
const createCsvWriter = require('csv-writer').createObjectCsvStringifier;

const csvWriter = createCsvWriter({
    path: 'activity.csv',
    header: [
        {id: 'title', title: 'title'},
        {id: 'time', title: 'time'},
        {id: 'products', title: 'products'},
        {id: 'misc', title: 'misc'},
        {id: 'used', title: 'used'}
    ]
});

const months = ["Jan", "Feb", "Mar",
				"Apr", "May", "Jun",
				"Jul", "Aug", "Sep",
				"Oct", "Nov", "Dec"];

let bodyStarted = false;
let block = "";
let writeBatchSize = 2000, total = 0;
let activities = [];

const parser =  new htmlparser.Parser({
	onopentag: function(name, attribs){
        if(name === "body" ){
            console.log("Valid html");
            bodyStarted = true;
        }

        if(bodyStarted) {
        	if(attribs.class === 'mdl-grid') {
        		// console.log("\n");
        		parseChunk(block);

        		if(activities.length == writeBatchSize) {
        			
        		}

        		block = "";
        	}
        }
    },
    ontext: function(text){
    	if(bodyStarted == true && text.trim() != "") {
        	block += "\n" + text;
    	}
    },
    onclosetag: async function(tagname){
    	if(tagname === "body"){
            console.log("Html parsing completed");
        	bodyStarted = false;

        	if(block)
        		parseChunk(block);

        	if(activities.length) {
				await writeToCsv(activities);
				activities = [];
			}
        }
    }
}, {decodeEntities: false});

const parseChunk = (block) => {
	if(block.trim() != "") {
		let activity = {};

		let lines = block.split('\n');
		for(let i = 0; i < lines.length; i++) {
			let l = lines[i];

			if(l.trim() === "")
				continue;
			//first line. Always title
			if(i == 1)
				activity.title = l;
			else {
				if(l.startsWith("Used&nbsp;")) {
					l = l.replace("Used&nbsp;", "");

					if(l.trim() != "")
						activity.used = l.trim();
					else
						activity.used = lines[++i];
				} else if(l.startsWith("Viewed&nbsp;")) {
					l = l.replace("Viewed&nbsp;", "");

					if(l.trim() != "")
						activity.viewed = l.trim();
					else
						activity.viewed = lines[++i];
				}
				else if(l.startsWith("Products:")) {
					activity.products = lines[++i].replace("&emsp;", "");
				} else if(l.startsWith("Details:")) {
					activity.details = lines[++i].replace("&emsp;", "");
				} else {
					let parsedDate = parseDate(l)
					if(parsedDate) activity.time = parsedDate;
					else activity.misc = l;
				} 
			}
		}

		fixIncompletelines(activity);
		activities.push(activity);
		total++;
	}
}

async function writeToCsv(records) {
	return new Promise((resolve, reject) => {
	    writeStream.write(csvWriter.stringifyRecords(records), 
	    	'utf8', () => resolve());
	  });
}

const fixIncompletelines = (activity)  => {
	if(activity.used){
		if(activity.title != activity.used) {
			if(activity.misc) {
				if(activity.title + activity.misc === activity.used) {
					activity.title = activity.used;
					activity.misc = null;
				}
				else if(activity.used + activity.misc == activity.title) {
					activity.used = activity.title;
					activity.misc = null;
				}
			}	
		} 

		if(activity.used == activity.title)
			activity.used = null;
	} 
}

const parseDate = (dateString) => {
	let month = dateString.substr(0, 3);
	if(months.indexOf(month) != -1) {
		dateString = dateString.replace("IST", "GMT+530");
		return new Date(dateString);
	}
}

const writeStream = fs.createWriteStream('activity.csv');
writeStream.write(csvWriter.getHeaderString(), () => {
	startReading();
});

function startReading() {
	const stream = fs.createReadStream('Takeout/My Activity/Android/MyActivity.html',
	 {encoding: 'utf-8'});

	stream.on('data', data => {
		parser.write(data);
	});

	stream.on('close', async () => {
		console.log("Total activity parsed: ", total);
	});
	
}

