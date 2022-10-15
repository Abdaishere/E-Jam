package Instructions;

import java.time.LocalDateTime;

abstract public class Instruction implements Runnable {
    LocalDateTime time;

    public Instruction(LocalDateTime time) {
        this.time = time;
    }
    abstract public void run();
    abstract public String toString();

}
