// HelloWorld.java

import java.awt.AWTEvent;
import java.awt.MouseInfo;
import java.awt.Toolkit;
import java.awt.event.AWTEventListener;

import javax.swing.JFrame;

public class HelloWorld{
    
    public HelloWorld(){
        setVersion(0);
    }
    
    public static void main(String[] args){
        Toolkit.getDefaultToolkit().addAWTEventListener(
        new Listener(), AWTEvent.MOUSE_EVENT_MASK | AWTEvent.FOCUS_EVENT_MASK);
        JFrame frame = new JFrame();
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setVisible(true);
        
        System.out.println("Hello World!");
    }
    
    private static class Listener implements AWTEventListener {
        public void eventDispatched(AWTEvent event) {
            System.out.print(MouseInfo.getPointerInfo().getLocation() + " | ");
            //System.out.println(event);
        }
    }
    
    public void setVersion(int aVersion){
        if( aVersion < 0 ){
            System.err.println("Improper version specified.");
        }
        else{
            version = aVersion;
        }
    }
    
    public int getVersion(){
        return version;
    }
    
    
    private int version;
    
}