/** @format */

import React, { useState } from "react";
import { Box, Text } from "native-base";
import { Image } from "react-native";

export default function VideoStream() {
	const [message, setMessage] = useState("");
	const [urlImage, setUrlImage] = useState(null);
	let uri = "https://www.pinterest.com/pin/671247519471624673/";
	return (
		<Box>
			<Image
				source={{
					uri: "https://www.pinterest.com/pin/671247519471624673/",
				}}
				style={{
					flex: 0.2,
					width: 55,
					height: 55,
					resizeMode: "contain",
				}}
				alt='pinterest'
			/>
			<Image
				source={{
					uri: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADMAAAAzCAYAAAA6oTAqAAAAEXRFWHRTb2Z0d2FyZQBwbmdjcnVzaEB1SfMAAABQSURBVGje7dSxCQBACARB+2/ab8BEeQNhFi6WSYzYLYudDQYGBgYGBgYGBgYGBgYGBgZmcvDqYGBgmhivGQYGBgYGBgYGBgYGBgYGBgbmQw+P/eMrC5UTVAAAAABJRU5ErkJggg==",
				}}
				style={{
					flex: 0.2,
					width: 55,
					height: 55,
					resizeMode: "contain",
				}}
			/>
			<Text>Hello, world!</Text>
		</Box>
	);
}
