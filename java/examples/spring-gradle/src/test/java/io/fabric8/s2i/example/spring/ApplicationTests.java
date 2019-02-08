package io.fabric8.s2i.example.spring;

import static org.junit.Assert.assertEquals;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class ApplicationTests {

    @LocalServerPort int localServerPort;

    @Test
    public void contextLoads() {
    }

    @Test
    public void testServer() throws IOException {
        HttpURLConnection con = (HttpURLConnection) new URL("http://localhost:" + localServerPort).openConnection();
        con.setConnectTimeout(500);
        con.setReadTimeout(500);
        assertEquals(200, con.getResponseCode());
    }
}
