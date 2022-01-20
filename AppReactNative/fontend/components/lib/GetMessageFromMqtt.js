
/** @format */

import React, { useState } from "react";
import axios from "axios";
import { Button, Text, Image, Center } from "native-base";
// import Paho from 'paho-mqtt'

export default function Message() {
	const [message, setMessage] = useState("");
	setInterval(() => {
		axios
			.get(`http://192.168.1.8:3000/mqtt`)
			.then((res) => {
				if (res.data.toString() === "") {
				} else {
					setMessage(`data:image/png;base64,${res.data.toString()}`);
				}
				// console.log(message);
			})
			.catch((error) => console.log(error));
	}, 100);
	return (
		<Center>
			<Text>{message}</Text>
			<Image
				alt='image'
				source={{
					uri: message,
				}}
				style={{
					flex: 1,
					width: 640,
					height: 480,
					resizeMode: "contain",
				}}
			/>
			<Text>Get message</Text>
		</Center>
	);
}
