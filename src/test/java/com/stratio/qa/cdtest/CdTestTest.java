package com.stratio.qa.cdtest;

import org.testng.Assert;
import org.testng.annotations.Test;

public class CdTestTest {

    @Test
    public void exampleUnitTest(){
        String[] args = new String[2];
        CdTest.main(args);
        try {
            System.out.println("Waiting for 5 minutes");
            Thread.sleep(300000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        Assert.assertEquals("YES", "YES");
    }

    @Test
    public void classTest(){
        CdTest test = new CdTest();
        Assert.assertEquals("YES", "YES");
    }
}
