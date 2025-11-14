# x86-64 Web Server (Assembly)

A simple (and gloriously reckless) HTTP server written entirely in x86‑64 assembly.  
I originally wrote this to complete a "dojo" in pwn.college — then it mutated into something that actually works… sometimes.

## Features

- Listens on port **80** like a *real* server (root privileges not included).
- Accepts both **GET** and **POST** requests.
- Extracts request paths by aggressively scanning for `/` like a confused archaeologist.
- Forks a **child process** for each client:
  - **Parent** immediately goes back to listening.
  - **Child** deals with whatever chaos the client sends.
- GET: Opens a file, reads it, and sends it back.
- POST: Finds the POST body after the `\r\n\r\n` boundary, writes it to a file.
- Responds with the highly‑professional:
because standards are for people with time.

> ⚠️ This entire project is *absolutely not* production-ready.  
> It’s basically "web‑server‑but-make-it-assembly" speed‑run edition.

## New File: `flexible-Web-Server`

This new version is slightly more flexible, slightly less cursed, and still written in pure assembly (because bad decisions snowball).

### What It Does

- Boots up as a **server process listening on port 80**.
- Accepts incoming requests like a bouncer who doesn't check IDs.
- On each connection:
- **Forks** a child.
- **Parent** returns to listening.
- **Child** handles the incoming request.

### Request Handling Logic

1. Read the request into a big buffer (`buf`).  
2. Extract the **path** by finding the first `/` and copying until a space.  
3. Inspect the **first letter** of the HTTP method:
 - `'G'` → GET request  
 - `'P'` → POST request  
 - Anything else → nope, goodbye
4. For **GET**:
 - Opens the file named in the request path.
 - Reads its content.
 - Sends it back to the client.
5. For **POST**:
 - Searches for the `\r\n\r\n` separator like it’s hunting treasure.
 - Everything after that is considered the **POST body**.
 - Writes the body into the file specified by the request path.
6. Sends back a universal response:
No headers, no MIME types, no shame.

### Why?

Because writing an HTTP server in assembly is like writing your résumé in binary:
- impressive,  
- unnecessary,  
- slightly worrying.

### Build

```bash
as -o Web-server.o Web-server.asm
ld -o Web-server Web-server.o
```



## Why Assembly?

- Because C is too mainstream.  
- Because Python sleeps while assembly awakens the inner masochist.  
- Because running `strace` on this makes you feel like a sysadmin wizard.  
- Because who doesn’t want to explain “yes, this tiny program really implements a web server, in assembly” at a party?

---

## Usage Examples

**Start the server:**

```bash
sudo ./Web-server or
sudo ./Flexible-Web-Server

