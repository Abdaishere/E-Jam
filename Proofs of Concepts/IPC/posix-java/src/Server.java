import java.io.File;
import java.nio.CharBuffer;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.file.StandardOpenOption;

public class Server {
    public static final String FILE_NAME = "/tmp/java-posix-test";
    public static final int N = (int)1e7;

    public static void main(String[] args) throws Throwable {
        long start = System.currentTimeMillis();

        File file = new File(FILE_NAME);

        FileChannel fileChannel = FileChannel.open(file.toPath(), StandardOpenOption.READ, StandardOpenOption.WRITE, StandardOpenOption.CREATE);

        MappedByteBuffer mappedByteBuffer = fileChannel.map(FileChannel.MapMode.READ_WRITE, 0, N * 200);
        CharBuffer charBuffer = mappedByteBuffer.asCharBuffer();

        char c;
        while ((c = charBuffer.get()) != '\0') {
//            System.out.print(c);
        }

        long end = System.currentTimeMillis();
        long elapsedTime = end - start;
        System.out.println("Total time = " + elapsedTime);
    }
}