import java.io.File;
import java.nio.CharBuffer;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;

public class Client {
    public static final String FILE_NAME = "/tmp/java-posix-test";
    public static final int N = (int)1e7;

    public static void main( String[] args ) throws Throwable {
        ArrayList<String> requests = new ArrayList<>();
        for (int i = 0; i < N; i++) {
            requests.add("a".repeat(10));
        }

        long start = System.currentTimeMillis();

        File file = new File(FILE_NAME);
        FileChannel fileChannel = FileChannel.open(file.toPath(), StandardOpenOption.READ, StandardOpenOption.WRITE, StandardOpenOption.CREATE);

        MappedByteBuffer mappedByteBuffer = fileChannel.map(FileChannel.MapMode.READ_WRITE, 0, N * 200);
        CharBuffer charBuffer = mappedByteBuffer.asCharBuffer();

        charBuffer.clear();

        for (String request : requests) {
            charBuffer.put(request + '\n');
//            System.out.println("Data written in memory: " + request);
        }

        charBuffer.put("\0");

        long end = System.currentTimeMillis();
        long elapsedTime = end - start;
        System.out.println("Total time = " + elapsedTime);
    }

}