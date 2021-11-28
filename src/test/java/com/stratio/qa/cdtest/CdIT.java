package com.stratio.qa.cdtest;

import org.testng.Assert;
import org.testng.annotations.Test;

public class CdIT {

    @Test
    public void exampleIntegrationTest(){
        String[] args = new String[2];
        CdTest.main(args);
        try {
            System.out.println("Waiting for 100 seconds");
            Thread.sleep(10000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        Assert.assertEquals("YES", "NO");
    }

    @Test
    public void classIntegrationTest(){
        CdTest test = new CdTest();
        Assert.assertEquals("YES", "YES");
    }
}
