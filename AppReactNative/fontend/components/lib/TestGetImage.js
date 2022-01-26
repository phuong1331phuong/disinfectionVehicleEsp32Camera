

/** @format */

import React, { useState, useEffect, useRef } from "react";
import axios from "axios";
import { Image } from "react-native";
import { Button, VStack, Text, Center, Box } from "native-base";
// import Paho from 'paho-mqtt'

export default function Message() {
	return (
		<Center>
			{/* <Text>{message}</Text> */}
			<Image
				alt='stream from esp32'
				source={{
                    uri: "http://192.168.1.8:3001/mqtt",
				}}
				style={{
					flex: 0.5,
					width: 320,
					height: 240,
				}}
			/>
			<Text>Get message</Text>
		</Center>
	);
}
