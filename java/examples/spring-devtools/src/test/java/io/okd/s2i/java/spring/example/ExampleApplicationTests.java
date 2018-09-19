package io.okd.s2i.java.spring.example;

import static org.junit.Assert.assertEquals;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment=WebEnvironment.RANDOM_PORT)
public class ExampleApplicationTests {

    @Autowired private TestRestTemplate restTemplate;

    @Test
    public void contextLoads() {
    }

    @Test
    public void testHelloXorld() {
        ResponseEntity<String> responseEntity = restTemplate.getForEntity("/hello", String.class);

        assertEquals(HttpStatus.OK, responseEntity.getStatusCode());
        assertEquals("hello, xorld", responseEntity.getBody());
    }
}
