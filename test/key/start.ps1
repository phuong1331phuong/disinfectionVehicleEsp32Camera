#!/usr/bin/env bash
# requires: Nodejs/NPM, PowerShell
# Permission to run PS scripts (for this session only):
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# exit if cmdlet gives error
$ErrorActionPreference = "Stop"

# Check to see if root CA file exists, download if not
If (!(Test-Path ".\root-CA.crt")) {
    "`nDownloading AWS IoT Root CA certificate from AWS..."
    Invoke-WebRequest -Uri https://www.amazontrust.com/repository/AmazonRootCA1.pem -OutFile root-CA.crt
}

# install AWS Device SDK for NodeJS if not already installed
node -e "require('aws-iot-device-sdk')"
If (!($?)) {
    "`nInstalling AWS SDK..."
    npm install aws-iot-device-sdk
}

"`nRunning pub/sub sample application..."
node .\node_modules\aws-iot-device-sdk\examples\device-example.js --host-name a3ylcu9d7zkfu-ats.iot.us-east-1.amazonaws.com --private-key .\phuong-nguyen.private.key --client-certificate .\phuong-nguyen.cert.pem --ca-certificate .\root-CA.crt --client-id=sdk-nodejs-4d9ed5a4-534f-4da3-a784-8b02571bf6fe
