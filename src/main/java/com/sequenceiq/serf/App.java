package com.sequenceiq.serf;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import org.msgpack.core.*;
import org.msgpack.value.ImmutableMapValue;
import org.msgpack.value.ImmutableValue;
import org.msgpack.value.Value;

/**
 * Hello world!
 *
 */
public class App
{
    //@Message // Annotation
    public static class MyMessage {
        // public fields are serialized.
        public String name;
        public double version;
    }
    public static MessageUnpacker unpacker;

    public static void readMap() throws Exception {
        ImmutableValue value = unpacker.unpackValue();
        System.out.println("=====>");
        ImmutableMapValue mapValue = value.asMapValue();
        for (java.util.Map.Entry<Value,Value> entry:mapValue.entrySet()) {
            System.out.println(entry);
        }
    }
    public static void main( String[] args ) throws Exception {
        System.err.println("connecting to serf ...");

        Socket client = new Socket("127.0.0.1", 7373);
        InputStream inputStream = client.getInputStream();
        OutputStream outputStream = client.getOutputStream();

        MessagePacker packer = MessagePack.newDefaultPacker(outputStream);
        unpacker = MessagePack.newDefaultUnpacker(inputStream);

        packer.packMapHeader(2);
        packer.packString("Command");
        packer.packString("handshake");
        packer.packString("Seq");
        packer.packByte((byte) 1);

        packer.packMapHeader(1);
        packer.packString("Version");
        packer.packByte((byte) 1);

        packer.flush();
        readMap();

        packer.packMapHeader(2);
        packer.packString("Command");
        packer.packString("members");
        packer.packString("Seq");
        packer.packByte((byte) 2);
        packer.flush();
        readMap();
        readMap();

        unpacker.close();
        packer.close();
        client.close();
    }
}
