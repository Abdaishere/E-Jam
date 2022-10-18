import java.io.*;
import java.net.Socket;
import java.util.*;

public class Client {
    public static final String IP = "127.0.0.1";
    public static final int PORT = 5000;

    public Client(String ip, int port) throws IOException {

        // set timer for 5 min
        long timer = 5 * 60 * 1000, counter = 0;

        long startTest = System.currentTimeMillis();
        long endTest = System.currentTimeMillis();

        // create a socket to communicate to the specified host and port
        Socket socket = new Socket(ip, port);

        // create a stream for reading from this socket
        BufferedReader fromServer = new BufferedReader(new InputStreamReader(socket.getInputStream()));

        // create a stream for writing to this socket
        PrintStream printStream = new PrintStream(socket.getOutputStream());

        String request = "a".repeat(10);

        while (endTest - startTest < timer) {
            // send request to the server
            printStream.println(request);

            // receive response from the server
            String response = fromServer.readLine();
//            System.out.println("Server responded: " + response);

            counter++;
            endTest = System.currentTimeMillis();
        }

        fromServer.close();
        printStream.close();
        socket.close();

        long elapsedTime = endTest - startTest;
        System.out.println("Total time = " + elapsedTime);
        System.out.println("Sent requests = " + counter);
    }

    public static void main(String[] args) throws IOException {
        new Client(IP, PORT);
    }
}