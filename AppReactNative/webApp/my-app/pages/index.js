/** @format */

import { Image, ChakraProvider, Box, Text } from "@chakra-ui/react";
import { useState, useEffect } from "react";
import axios from "axios";

export default function Home() {
	const [message, setMessage] = useState("");
	setInterval(() => {
		axios
			.get("http://192.168.1.8:3001/mqtt")
			.then((res) => {
				setMessage(res.data.toString());
			})
			.catch((error) => {
				console.log(error);
			});
	}, 100);
	return (
		<ChakraProvider>
			<Box>
				<Text>{message}</Text>
				<Image
					src={`data:image/png;base64,${message}`}
					alt='video stream'
					width='600px'
					height='480px'
				/>
			</Box>
		</ChakraProvider>
	);
}
