# x86-64 Web Server (Assembly)

A simple HTTP server written in x86-64 assembly.  
I have written this to complete a "dojo" in pwn.college

## Features

- Listens on port 5000
- Accepts POST requests
- Extracts the POST body and writes it to a file
- Forks a child process for each client

## Build

```bash
as -o Web-server.o Web-server.asm
ld -o Web-server Web-server.o
```
