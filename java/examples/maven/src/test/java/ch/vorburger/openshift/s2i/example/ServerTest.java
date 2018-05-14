/*
 * #%L
 * ch.vorburger.openshift
 * %%
 * Copyright (C) 2018 - 2018 Michael Vorburger
 * %%
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * #L%
 */
package ch.vorburger.openshift.s2i.example;

import static org.junit.Assert.assertEquals;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import org.junit.Test;

/**
 * Unit test
 * @author Michael Vorburger.ch
 */
public class ServerTest {

    @Test
    public void testServer() throws IOException {
        Server server = new Server();

        HttpURLConnection con = (HttpURLConnection) new URL("http://localhost:8080/").openConnection();
        con.setConnectTimeout(500);
        con.setReadTimeout(500);
        assertEquals(200, con.getResponseCode());

        server.close();
    }

}
