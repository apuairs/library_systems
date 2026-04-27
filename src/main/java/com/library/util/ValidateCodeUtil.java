package com.library.util;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Random;

public class ValidateCodeUtil {
    
    private static final int WIDTH = 100;
    private static final int HEIGHT = 38;
    private static final int CODE_LENGTH = 4;
    private static final String CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789";
    
    public static String generateCode() {
        Random random = new Random();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < CODE_LENGTH; i++) {
            int index = random.nextInt(CODE_CHARS.length());
            sb.append(CODE_CHARS.charAt(index));
        }
        return sb.toString();
    }
    
    public static void outputImage(String code, OutputStream os) throws IOException {
        BufferedImage image = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics g = image.getGraphics();
        
        // 背景
        g.setColor(Color.WHITE);
        g.fillRect(0, 0, WIDTH, HEIGHT);
        
        // 边框
        g.setColor(Color.BLACK);
        g.drawRect(0, 0, WIDTH - 1, HEIGHT - 1);
        
        // 干扰线
        Random random = new Random();
        g.setColor(Color.LIGHT_GRAY);
        for (int i = 0; i < 10; i++) {
            int x1 = random.nextInt(WIDTH);
            int y1 = random.nextInt(HEIGHT);
            int x2 = random.nextInt(WIDTH);
            int y2 = random.nextInt(HEIGHT);
            g.drawLine(x1, y1, x2, y2);
        }
        
        // 验证码
        g.setFont(new Font("Arial", Font.BOLD, 24));
        for (int i = 0; i < code.length(); i++) {
            g.setColor(new Color(random.nextInt(200), random.nextInt(200), random.nextInt(200)));
            g.drawString(String.valueOf(code.charAt(i)), 15 + i * 20, 28);
        }
        
        g.dispose();
        ImageIO.write(image, "JPEG", os);
    }
}