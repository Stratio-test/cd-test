package com.stratio.qa.cdtest;

import org.testng.Assert;
import org.testng.annotations.Test;

public class CdTestTest {

    @Test
    public void exampleUnitTest() throws Exception{
        String[] args = new String[2];
        CdTest.main(args);
        try {
            System.out.println("Waiting for 5 seconds");
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        Assert.assertEquals("YES", "YES");
        throw new Exception("On purpose exception");
    }

    @Test
    public void classTest(){
        CdTest test = new CdTest();
        Assert.assertEquals("YES", "YES");
    }
}
