import java.io.IOException;
import java.io.PipedReader;
import java.io.PipedWriter;
import java.util.ArrayList;

public class Client {
    public static final int N = (int)1e5;
    public static PipedWriter writeToServer = new PipedWriter();
    public static PipedReader readFromServer = new PipedReader();

    public static void main(String[] args) throws IOException {

        ArrayList<String> requests = new ArrayList<>();
        for (int i = 1; i <= N; i++) {
            requests.add("a".repeat(10));
        }

        long start = System.currentTimeMillis();

        writeToServer.connect(Server.readFromClient);

        for (String request : requests) {
            writeToServer.write(request + '\n');

            int i;
            while ((char)(i = readFromServer.read()) != '\n') {
                System.out.print((char)i);
            }
            System.out.println();
        }

        writeToServer.close();
        readFromServer.close();

        long end = System.currentTimeMillis();
        long elapsedTime = end - start;
        System.out.println("Total time = " + elapsedTime);
    }
}
