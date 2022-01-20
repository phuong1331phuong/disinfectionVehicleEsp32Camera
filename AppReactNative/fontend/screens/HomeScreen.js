/** @format */

import React, { useState, useEffect } from "react";
import { Center, Box, Image } from "native-base";
import Message from "../components/lib/GetMessageFromMqtt";
import VideoStream from "../components/VideoStream";

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
			{/* <Box>{message}</Box> */}
			{/* <Image
				alt='image'
				source={{
					uri: message,
				}}
				style={{
					flex: 0.2,
					width: 640,
					height: 480,
					resizeMode: "contain",
				}}
			/> */}
			<Message />
			<VideoStream />
		</Center>
	);
}
