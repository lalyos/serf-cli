This repo collects my play with [serf](http://serfdom.io)'s protocol.
A bash serf client was born first, just to learn [MessagePack](http://msgpack.org) and serf protocol, in the lowest level possible.
That a java POC created to get serf members, it might be enhanced to a proper java library ...

## Install serf

On osx use brew:
```
$ brew install serf

$ serf --version
Serf v0.7.0
Agent Protocol: 4 (Understands back to: 2)
```

## Start serf agent

Lets start a serf agent, so that we can see all events:

```
serf agent -event-handler=./handler.sh -log-level=debug
```

## Bash cli

The bash implementation of serf client relies on [msgpack-cli](https://github.com/jakm/msgpack-cli).
msgpack-cli is command line tool that converts data from JSON to Msgpack and vice versa.

Install msgpack-cli:
```
go get github.com/jakm/msgpack-cli
```

```
./serf.sh members
```
You will see the decoded response. The Address field is base64 encoded ip address.
Where the ip address numbers are hexa encoded.


```
./serf.sh event hello
```
You should check the agent output, to see the dump of the custom event.

## Java client

The java implementation is using the [msgpack-java](https://github.com/msgpack/msgpack-java) library.
To build with maven:
```
mvn package
```

To call `members` command:
```
mvn exec:java
```

## tl;dr

### Serf RPC protocol:

The RPC protocol is implemented using [MsgPack](http://msgpack.org) over TCP.
A typical serf command flow is:
- OPEN a connection to port **7373**
- SEND Handshake command
- READ Response
- SEND actual command (members/event/join/...)
- READ Response
- CLOSE connection

Each command has a header: '{"Command": "handshake", "Seq": <num>}' followed by an **optional** body.

Each command increases the **Seq**, which starts from 1

### Handshake
The hanshake itself is a command, with a simple body `{"Version": 1}`
So the begining of a communication is always start with:
```
{"Command": "handshake", "Seq": 0}
{"Version": 1}
```

### Members

The members command has no body, just a header:
```
{"Command": "members", "Seq": 1}
```

### Event

The event command has a body with **Name** and **Payload**.
```
{"Command": "event", "Seq": 1}
{"Name": "foo", "Payload": "test payload", "Coalesce": true}

```

### More commands

For full detais see the official [docs](http://msgpack.org)
