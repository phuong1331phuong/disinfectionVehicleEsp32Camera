/** @format */

import { Box } from "native-base";
import React, { useState, useEffect } from "react";
import { Button, Text } from "native-base";
import mqtt from "mqtt/dist/mqtt";

const TRUSTED_CA_LIST = "-----BEGIN CERTIFICATE-----\
MIIF3jCCA8agAwIBAgIQAf1tMPyjylGoG7xkDjUDLTANBgkqhkiG9w0BAQwFADCB\
iDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0pl\
cnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNV\
BAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTAw\
MjAxMDAwMDAwWhcNMzgwMTE4MjM1OTU5WjCBiDELMAkGA1UEBhMCVVMxEzARBgNV\
BAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVU\
aGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2Vy\
dGlmaWNhdGlvbiBBdXRob3JpdHkwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIK\
AoICAQCAEmUXNg7D2wiz0KxXDXbtzSfTTK1Qg2HiqiBNCS1kCdzOiZ/MPans9s/B\
3PHTsdZ7NygRK0faOca8Ohm0X6a9fZ2jY0K2dvKpOyuR+OJv0OwWIJAJPuLodMkY\
tJHUYmTbf6MG8YgYapAiPLz+E/CHFHv25B+O1ORRxhFnRghRy4YUVD+8M/5+bJz/\
Fp0YvVGONaanZshyZ9shZrHUm3gDwFA66Mzw3LyeTP6vBZY1H1dat//O+T23LLb2\
VN3I5xI6Ta5MirdcmrS3ID3KfyI0rn47aGYBROcBTkZTmzNg95S+UzeQc0PzMsNT\
79uq/nROacdrjGCT3sTHDN/hMq7MkztReJVni+49Vv4M0GkPGw/zJSZrM233bkf6\
c0Plfg6lZrEpfDKEY1WJxA3Bk1QwGROs0303p+tdOmw1XNtB1xLaqUkL39iAigmT\
Yo61Zs8liM2EuLE/pDkP2QKe6xJMlXzzawWpXhaDzLhn4ugTncxbgtNMs+1b/97l\
c6wjOy0AvzVVdAlJ2ElYGn+SNuZRkg7zJn0cTRe8yexDJtC/QV9AqURE9JnnV4ee\
UB9XVKg+/XRjL7FQZQnmWEIuQxpMtPAlR1n6BB6T1CZGSlCBst6+eLf8ZxXhyVeE\
Hg9j1uliutZfVS7qXMYoCAQlObgOK6nyTJccBz8NUvXt7y+CDwIDAQABo0IwQDAd\
BgNVHQ4EFgQUU3m/WqorSs9UgOHYm8Cd8rIDZsswDgYDVR0PAQH/BAQDAgEGMA8G\
A1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQEMBQADggIBAFzUfA3P9wF9QZllDHPF\
Up/L+M+ZBn8b2kMVn54CVVeWFPFSPCeHlCjtHzoBN6J2/FNQwISbxmtOuowhT6KO\
VWKR82kV2LyI48SqC/3vqOlLVSoGIG1VeCkZ7l8wXEskEVX/JJpuXior7gtNn3/3\
ATiUFJVDBwn7YKnuHKsSjKCaXqeYalltiz8I+8jRRa8YFWSQEg9zKC7F4iRO/Fjs\
8PRF/iKz6y+O0tlFYQXBl2+odnKPi4w2r78NBc5xjeambx9spnFixdjQg3IM8WcR\
iQycE0xyNN+81XHfqnHd4blsjDwSXWXavVcStkNr/+XeTWYRUc+ZruwXtuhxkYze\
Sf7dNXGiFSeUHM9h4ya7b6NnJSFd5t0dCy5oGzuCr+yDZ4XUmFF0sbmZgIn/f3gZ\
XHlKYC6SQK5MNyosycdiyA5d9zZbyuAlJQG03RoHnHcAP9Dc1ew91Pq7P8yF1m9/\
qS3fuQL39ZeatTXaw2ewh0qpKJ4jjv9cJ2vhsE/zB+4ALtRZh8tSQZXq9EfX7mRB\
VXyNWQKV3WKdwrnuWih0hKWbt5DHDAff9Yk2dDLWKMGwsAvgnEzDHNb842m1R0aB\
L6KCq9NjRHDEjf8tM7qtj3u1cIiuPhnPQCjY/MiQu12ZIvVS5ljFH4gxQ+6IHdfG\
jjxDah2nGN59PRbxYvnKkKj9\
-----END CERTIFICATE-----"
export default function Message() {
	const options = {
        host: "broker.emqx.io",
        port: 1883,
		// The CA list will be used to determine if server is authorized
		// Clean session
		connectTimeout: 4000,
		// Auth
		clientId: "mqttx_2a634c9a",
		username: "phuongbgbg",
		password: "1234567",
        protocol:"mqtt",
		// protocol: "mqtts",
		keepalive: 10,
		clean: true,
		// reconnectPeriod: 2000,
        // ca: TRUSTED_CA_LIST,
		// rejectUnauthorized: true,
	};
	const [isSubed, setIsSub] = useState(false);
	const [payload, setPayload] = useState({});
	const [connectStatus, setConnectStatus] = useState("Connect");
	const [client, setClient] = useState(null);
	const mqttConnect = (url, options) => {
		setConnectStatus("Connecting");
		setClient(mqtt.connect(url,options));
	};
	useEffect(() => {
		if (client) {
            console.log(client.options.protocol);
            console.log(process.title);
			client.on("connect", () => {
				mqttSub({
					topic: "esp32/test",
					qos: 0,
				});
				setConnectStatus("Connected");
			});
			client.on("error", (err) => {
				console.error("Connection error: ", err);
				setConnectStatus("Error");
				client.end();
			});
			client.on("reconnect", () => {
				setConnectStatus("Reconnecting");
			});
			client.on("message", (topic, message) => {
				const payload = { topic, message: message.toString() };
				console.log(message.toString());
				setPayload(payload);
			});
		}
	}, [client]);
	const mqttSub = (subscription) => {
		if (client) {
			const { topic, qos } = subscription;
			client.subscribe(topic, { qos }, (error) => {
				if (error) {
					console.log("Subscribe to topics error", error);
					return;
				}
				setIsSub(true);
			});
		}
	};
	const mqttDisconnect = () => {
		if (client) {
			client.end(() => {
				setConnectStatus("Connect");
			});
		}
	};
	const mqttPublish = (context) => {
		if (client) {
			const { topic, qos, payload } = context;
			client.publish(topic, payload, { qos }, (error) => {
				if (error) {
					console.log("Publish error: ", error);
				}
			});
		}
	};
	const mqttUnSub = (subscription) => {
		if (client) {
			const { topic } = subscription;
			client.unsubscribe(topic, (error) => {
				if (error) {
					console.log("Unsubscribe error", error);
					return;
				}
				setIsSub(false);
			});
		}
	};

	return (
		<Box>
			<Button
				value='connect'
				onPress={() => {
                    mqttConnect(options);
				}}
			/>
			<Text>{connectStatus}</Text>
			<Button
				value='click'
				onPress={() => {
					mqttPublish({
						topic: "esp32/test",
						qos: 1,
						payload: "dexem co gui dc ko",
					});
				}}
			/>
			<Text>{payload.Message}</Text>
		</Box>
	);
}
