/** @format */

const express = require("express");
const mqtt = require("mqtt");
const app = express();
const port = 3001;

const client = mqtt.connect("mqtt://broker.emqx.io:1883", {
	clientId: "mqtt_jsksy554",
	username: "phuongbgbg",
	password: "1234567",
	clean: true,
});

const topic = "esp32/test/phuong/dep/trai";
client.on("connect", () => {
	console.log("Connected");
	client.subscribe([topic], () => {
		console.log(`Subscribe to topic '${topic}'`);
	});
	client.publish(
		topic,
		"nodejs mqtt test",
		{ qos: 0, retain: false },
		(error) => {
			if (error) {
				console.error(error);
			}
		}
	);
});

let mesg = "";
client.on("message", (topic, payload) => {
	// console.log("Received Message:", topic, payload.toString());
	mesg = payload.toString();
});

app.get("/mqtt", (req, res) => {
	res.send(mesg);
});

app.listen(port, () => {
	console.log(`Example app listening at http://localhost:${port}`);
});
