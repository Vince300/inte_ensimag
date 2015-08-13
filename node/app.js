var pg = require('pg'),
	log = require('npmlog'),
	EventEmitter = require('events').EventEmitter,
	util = require('util'),
	WebSocketServer = require('ws').Server;

// The database connection string
var pgConString = process.env.INTE_DATABASE_URL;

// Create event object
var changeEvent = new EventEmitter();
changeEvent.on('error', function(e) {
	log.error('EventListener', 'An error occured', util.inspect(e));
});

// Setup database listener
pg.connect(pgConString, function(err, client) {
	if (err) {
		log.error('PostgreSQL', err);
	}

	client.on('notification', function(e) {
		if (e.channel != 'teams') {
			log.warn('PostgreSQL', "Unexpected notification for channel " + e.channel);
			return;
		}

		log.info('PostgreSQL', "Got notification for channel " + e.channel);

		// Emit the event in the payload
		changeEvent.emit(e.payload);
	});

	client.query("LISTEN teams");
});

// Setup Websocket server
var wss = new WebSocketServer({ host: '127.0.0.1', port: 9292 });

log.info('WS', "Started listening...");

wss.on('connection', function(ws) {
	var req = ws.upgradeReq;
	var remote = req.headers['x-forwarded-for'] || req.connection.remoteAddress;

	if (req.url === "/inte/events") {
		log.info('WS', "Added new client " + remote);

		// The function that will handle teams_changed events from the database
		var handler = function() {
			log.info('HTTP', "Sending notification to " + remote);
			ws.send('teams_changed');
		};

		// Setup the event listener
		changeEvent.on('teams_changed', handler);

		// Remove the listener on connection close
		ws.on('close', function() {
			log.info('HTTP', "Closed connection for " + remote);
			changeEvent.removeListener('teams_changed', handler);
		})
	} else {
		log.warn('HTTP', "Unexpected request for " + req.url + " from " + remote);
		res.writeHead(404);
		res.end();
	}
});
