package Instructions;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Connect extends Instruction{
    String Target;

    public Connect(LocalDateTime time, String target) {
        super(time);
        Target = target;
    }

    @Override
    public void run() {
        System.out.println("\u001B[32m" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy:MM:dd:HH:mm:ss.SSSSSS")) + " Connecting : " + Target + "\u001B[0m");
    }

    @Override
    public String toString() {
        return super.toString() +  " Connecting : " + Target;
    }
}
