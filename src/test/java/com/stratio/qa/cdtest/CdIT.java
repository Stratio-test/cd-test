package com.stratio.qa.cdtest;

import org.testng.Assert;
import org.testng.annotations.Test;

public class CdIT {

    @Test(groups={"integration"})
    public void exampleIntegrationTest(){
        String[] args = new String[2];
        String a = "a";
        if(a == "a"){
            System.out.println("a comparation");
        }
        CdTest.main(args);
        try {
            System.out.println("Waiting for 1 second");
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        Assert.assertEquals("YES", "YES");
    }

    @Test
    public void classIntegrationTest(){
        CdTest test = new CdTest();
        String a = "a";
        if(a == "a"){
            System.out.println("a comparation");
        }
        Assert.assertEquals("YES", "YES");
    }
}
