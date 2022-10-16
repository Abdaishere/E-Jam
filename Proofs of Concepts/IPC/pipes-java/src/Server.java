import java.io.IOException;
import java.io.PipedReader;
import java.io.PipedWriter;
import java.util.ArrayList;

public class Server {
    public static final int N = (int)1e5;
    public static PipedWriter writeToClient = new PipedWriter();
    public static PipedReader readFromClient = new PipedReader();

    public static void main(String[] args) throws IOException {

        ArrayList<String> responses = new ArrayList<>();
        for (int i = 1; i <= N; i++) {
            responses.add("a".repeat(10));
        }

        long start = System.currentTimeMillis();

        writeToClient.connect(Client.readFromServer);

        for (String response : responses) {
            int i;
            while ((char)(i = readFromClient.read()) != '\n') {
                System.out.print((char)i);
            }

            writeToClient.write(response + '\n');
            System.out.println();
        }

        writeToClient.close();
        readFromClient.close();

        long end = System.currentTimeMillis();
        long elapsedTime = end - start;
        System.out.println("Total time = " + elapsedTime);
    }
}
