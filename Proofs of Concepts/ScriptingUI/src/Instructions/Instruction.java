package Instructions;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;

abstract public class Instruction implements Runnable {
    public LocalDateTime time;

    public Instruction(LocalDateTime time) {
        this.time = time;
    }
    abstract public void run();
    public String toString() {
        return time.format(DateTimeFormatter.ofPattern("yyyy:MM:dd:HH:mm:ss.SSSSSS"));
    }

    public static <T extends Comparable<? super T>> void sort(ArrayList<T> list) {

    }
}
