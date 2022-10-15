package Instructions;

import java.time.LocalDateTime;

public class Connect extends Instruction{
    String Target;

    public Connect(LocalDateTime time, String target) {
        super(time);
        Target = target;
    }

    @Override
    public void run() {
        System.out.println(time.toString() + "Connecting : " + Target);
    }

    @Override
    public String toString() {
        return time.toString() + "Connecting : " + Target;
    }
}
