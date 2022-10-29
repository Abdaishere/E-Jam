import java.util.concurrent.Semaphore;

class SharedMemory {
    String item, temp;
    // Con initialized with 0 permits to ensure put() executes first
    static Semaphore producerSemaphore = new Semaphore(1);
    static Semaphore consumerSemaphore = new Semaphore(0);

    void get() throws InterruptedException {
        // Before consumer can consume an item, it must acquire a permit from consumer
        consumerSemaphore.acquire();

        // consumer consuming an item
//        System.out.println("Consumer consumed item: " + item);
        temp = item;

        // After consumer consumes the item, it releases Prod to notify producer
        producerSemaphore.release();
    }

    void put(String item) throws InterruptedException {
        // Before producer can produce an item, it must acquire a permit from producer
        producerSemaphore.acquire();

        // producer producing an item
        this.item = item;

        // After producer produces the item, it releases Con to notify consumer
        consumerSemaphore.release();
    }
}

class Producer implements Runnable {
    SharedMemory sharedMemory;

    Producer(SharedMemory sharedMemory) {
        this.sharedMemory = sharedMemory;
        new Thread(this, "Producer").start();
    }

    @Override
    public void run() {
        try {
            sharedMemory.put("a".repeat(1048576));
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }
}

class Consumer implements Runnable {
    SharedMemory sharedMemory;

    Consumer(SharedMemory sharedMemory) {
        this.sharedMemory = sharedMemory;
        new Thread(this, "Consumer").start();
    }

    public void run() {
        try {
            sharedMemory.get();
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }
}

public class Main {

    public static void main(String[] args) {
        long timer = 5 * 60 * 1000, counter = 0;

        long startTest = System.currentTimeMillis();
        long endTest = System.currentTimeMillis();

        // creating buffer queue
        SharedMemory sharedMemory = new SharedMemory();

        while (endTest - startTest < timer) {
            // starting producer thread
            new Producer(sharedMemory);

            // starting consumer thread
            new Consumer(sharedMemory);

            counter++;
            endTest = System.currentTimeMillis();
        }

        long elapsedTime = endTest - startTest;
        System.out.println("Total time = " + elapsedTime);
        System.out.println("Total received = " + counter);
    }

}