
package banco.regresion;

import com.intuit.karate.junit5.Karate;

public class BancoTest {

    @Karate.Test
    Karate ejecutarRegresion() {
        return Karate.run("regresion").relativeTo(getClass());
    }
}
