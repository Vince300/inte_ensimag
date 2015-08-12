var pg = require('pg'),
	log = require('npmlog'),
	EventEmitter = require('events').EventEmitter,
	util = require('util'),
	http = require('http');

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

// Setup HTTP streaming
http.createServer(function(req, res) {
	if (req.url === "/") {
		// Start HTTP streaming
		res.writeHead(200, { "Content-Type": "text/event-stream",
							 "Cache-Control": "no-cache",
							 "Connection": "keep-alive" });

		log.info('HTTP', "Added new client " + req.socket.remoteAddress);

		// The function that will handle teams_changed events from the database
		var handler = function() {
			res.write("retry: 500\n");
			res.write("event: teams_changed\n\n");
		};

		// Setup the event listener
		changeEvent.on('teams_changed', handler);

		// Remove the listener on connection close
		req.connection.addListener("close", function() {
			log.info('HTTP', "Closed connection for " + req.socket.remoteAddress);
			changeEvent.removeListener('teams_changed', handler);
		});
	} else {
		res.writeHead(404);
		res.end();
	}
}).listen(80, '127.0.0.1');

log.info('HTTP', "Started listening...");
