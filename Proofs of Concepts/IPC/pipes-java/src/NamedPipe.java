//import java.io.File;
//import java.io.FileNotFoundException;
//import java.io.IOException;
//import java.io.RandomAccessFile;
//
//public class NamedPipe {
//    private RandomAccessFile pipe;
//    private String pipeName;
//
//    public NamedPipe(String pipeName) {
//        this.pipeName = pipeName;
//    }
//
//    public boolean openPipe() {
//        boolean done=false;
//        try {
//            pipe = new RandomAccessFile(pipeName, "rw");
//            done = true;
//        } catch (FileNotFoundException e) {
//            e.printStackTrace();
//            done = false;
//        }
//        return done;
//    }
//
//    public boolean closePipe() {
//        boolean done=false;
//        try {
//            pipe.close();
//            done=true;
//        } catch (IOException e) {
//            done=false;
//        }
//        return done;
//    }
//
//    public String readFromPipe() {
//        String str=null;
//        try {
//            str = pipe.readLine();
//        } catch (IOException e) {
//            // TODO Auto-generated catch block
//            e.printStackTrace();
//        }
//        return str;
//    }
//
//    public void writeToPipe(String str) throws IOException {
//        pipe.write(str.getBytes());
//    }
//
//    public boolean deletePipe() {
//        File f = new File(pipeName);
//        return f.delete();
//    }
//
//    public static void main(String[] args) {
//        NamedPipe pipe1 = new NamedPipe("pipe_1");
//        pipe1.writeToPipe();
//
//    }
//}