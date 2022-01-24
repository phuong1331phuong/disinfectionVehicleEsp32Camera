/** @format */

import React, { useState, useEffect } from "react";
import { Center, Box, Image } from "native-base";
import Message from "../components/lib/GetMessageFromMqtt";
// import DisplayVideo from "../components/lib/DisplayVideo";

export default function HomeScreen() {
	// let msg = Message();
	// const [message, setMessage] = useState("");
	// useEffect(() => {
	// 	setMessage(`data:image/png;base64, ${Message()} `);
	// }, [Message()]);
	return (
		<Center
			height='100%'
			_dark={{ bg: "gray.900", color: "gray.50" }}
			_light={{ bg: "gray.50", color: "gray.900" }}
			display='flex'>
			<Message />
		</Center>
	);
}
