# Advertencia de riesgos

Lea esto antes de usar el MarketAI Connector con dinero real. In English:
[DISCLAIMER.md](DISCLAIMER.md).

**Puede perder dinero, incluso más del que espera.** En un exchange de criptoactivos, el
conector opera con apalancamiento en futuros perpetuos. Cuando el precio se mueve en
contra de una posición apalancada, usted pierde un múltiplo de ese movimiento: con
apalancamiento 3x, un movimiento del 10 % en su contra le hace perder alrededor del 30 %
del dinero de esa posición. Con margen cruzado, una pérdida suficientemente grande puede
llevarse todo el saldo de su cuenta. En Alpaca, el conector compra acciones
estadounidenses, con dinero prestado por Alpaca cuando el apalancamiento del bot es
superior a 1x. Las pérdidas sobre el dinero prestado también son suyas: con 2x, una
caída del 10 % de sus acciones le hace perder alrededor del 20 % del valor de su cuenta,
y Alpaca puede exigirle más fondos (una llamada de margen o margin call) o vender sus
acciones por sí misma. Alpaca cobra intereses por el dinero que usted toma prestado y,
ante una caída brusca, la pérdida puede superar el valor de su cuenta.

**Las señales no son asesoramiento personalizado.** Los feeds de señales propios de
MarketAI proceden de modelos estadísticos, y todos los que siguen uno reciben las mismas
señales, sea cual sea su situación. Un feed de reglas sigue las reglas que usted mismo
establece; en Alpaca, la cartera objetivo es la cartera simulada de su propio bot,
calculada a partir de esas reglas y de la configuración de su bot. No comprobamos si esta
operativa es adecuada para usted, para su patrimonio o para su experiencia. Las
simulaciones sobre datos históricos (backtests) y los resultados reales pasados no
predicen los resultados futuros. Un feed puede perder dinero durante largos periodos.

**Cada orden es suya.** Las señales proceden de MarketAI; la decisión de seguirlas
automáticamente es suya. Una vez que inicia el conector, este coloca, modifica y cancela
órdenes en su cuenta por sí solo, sin consultarle antes. Al ejecutarlo, usted autoriza
esas órdenes, que, junto con sus resultados, son suyas sea cual sea su causa. Si un fallo
del conector o del servicio de MarketAI le causa una pérdida, la cláusula 10 de
LICENSE.es establece si debemos indemnizarle: si usa el conector para un negocio, no,
salvo dolo o culpa grave; si es consumidor, sí, en los términos que establece la ley y en
ninguno más. Revise su cuenta de exchange con regularidad, y detenga el conector de
inmediato si ve una orden que no esperaba. Para que deje de operar, pause sus bots en My
bots, lo que cierra sus posiciones (en Alpaca, las vende mientras el mercado está
abierto), o detenga el conector, lo que las deja abiertas con su stop-loss y su
take-profit (en Alpaca, el stop-loss de una fracción de acción caduca al final de esa
sesión).

**Las órdenes no siempre se ejecutan según lo previsto.** Un stop-loss se dispara como
orden a mercado y, en un mercado rápido, puede ejecutarse a un precio peor que su precio
de activación. Un take-profit queda en el libro de órdenes como orden limitada y puede no
ejecutarse cuando el precio solo lo toca. Los exchanges, las redes, MarketAI y su propio
ordenador pueden fallar o funcionar con lentitud. En un exchange de criptoactivos, una
señal enviada mientras el conector está desconectado no se vuelve a enviar; en Alpaca, el
conector aplica la cartera objetivo más reciente cuando vuelve a conectarse, dentro de
los límites que se describen a continuación. En Alpaca, las órdenes solo se ejecutan
mientras el mercado estadounidense está abierto. Un stop-loss solo se dispara entonces, de
modo que una acción cuya cotización abre por debajo del precio de su stop-loss se vende a
un precio cercano al de apertura, inferior al precio del stop-loss.

**Un bot de inversión en Alpaca sigue una cartera objetivo.** Tras cada barra (cada día,
en un feed diario), MarketAI envía el porcentaje del valor de la cuenta que debe
mantenerse en cada mercado del feed del bot, y el conector compra y vende para ajustarse
a él (cláusula 8.5 de LICENSE.es). Todas las ventas que realiza para seguir la cartera
objetivo se ejecutan a mercado. Lo que el feed compra en la apertura, el conector lo
compra con una orden a mercado en los primeros minutos tras la apertura, a cualquier
precio, que puede diferir del precio de apertura que utiliza el feed. Cualquier otra
cantidad que le falte a la cuenta (una barra que el conector no recibió, una orden que
Alpaca rechazó, un ingreso de fondos) solo la compra a un precio igual o inferior al
precio límite que envía MarketAI, y no la compra si MarketAI no envía ninguno; esa
compra, si no se ejecuta en pocos minutos, se cancela hasta la siguiente cartera
objetivo. Por ello, la cuenta puede mantener menos que el objetivo y sus resultados
pueden diferir de los de la cartera simulada del bot. El stop-loss y el take-profit son
los que el propio bot tiene configurados en My bots: un bot sin stop-loss no tiene
ninguno. El stop-loss de una posición comprada en la apertura se calcula primero a
partir de las primeras operaciones tras la apertura, y se traslada al precio oficial de
apertura cuando Alpaca lo publica, aproximadamente un cuarto de hora después. Las
acciones enteras mantienen su stop-loss y su take-profit hasta que se cancelan: por el
conector mientras compra más de esa acción, cuando lo exigen las normas de Alpaca, o por
Alpaca conforme a sus propias normas; mientras está en funcionamiento, el conector los
vuelve a colocar. Una fracción de acción lleva solo su stop-loss (o su take-profit, si
no tiene stop-loss), válido para la sesión en curso, que se vuelve a colocar cada día
mientras el conector está en funcionamiento. Si el precio ya ha superado un nivel cuando
se coloca su orden, el conector vende a mercado. Las propias normas de Alpaca, como las
relativas a la operativa intradía y al margen, pueden rechazar una orden o restringir su
cuenta.

**Algunos cambios en MarketAI cierran sus posiciones.** Cuando su bot está en pausa,
pendiente de aprobación por MarketAI o impagado, cuando se retira su feed de señales, y
cuando MarketAI comunica un estado que el conector no reconoce, el conector cierra todas
las posiciones abiertas (a mercado cuando una orden limitada no se ejecuta) y después
espera. Cuando usted cambia un bot a otro feed de señales, el conector cierra primero las
posiciones del feed anterior. Un cierre puede materializar una pérdida. Por ejemplo:
tiene una posición larga en BTC con apalancamiento 3x y su pago falla cuando BTC está un
5 % por debajo de su precio de entrada. El conector cierra a mercado y usted pierde
alrededor del 15 % del dinero de esa posición, más las comisiones. En Alpaca, estos casos
no cierran posiciones: el conector vende a mercado, de inmediato o en la siguiente
apertura, todas las acciones que la cuenta mantiene en los mercados del bot, y no compra
nada; un cambio a otro feed de reglas solo vende los mercados del feed anterior que el
nuevo no negocia. Cuando el bot se elimina o se sustituye su token, el conector deja de
operar y mantiene las posiciones abiertas tal como están, cada una con el stop-loss ya
colocado en el exchange, si lo tiene (en Alpaca, el conector lo mantiene mientras está en
funcionamiento).

**El conector se actualiza solo.** Una nueva versión se instala automáticamente,
normalmente en menos de un cuarto de hora, salvo que usted desactive las actualizaciones
automáticas. Una nueva versión puede cambiar el comportamiento del conector. Lo que
cambia cada versión está en las notas de versión:
https://github.com/sergimes/marketai-connector/releases.

**El software puede tener errores.** Se proporciona tal cual: véanse las cláusulas 9 y
10 de [LICENSE.es](LICENSE.es), que también indican qué derechos conserva como
consumidor. Use una clave API que **no pueda retirar fondos** cuando el exchange la
ofrezca, empiece con una **cuenta demo** (en Alpaca, una cuenta de simulación o paper) y
después con una cantidad que pueda permitirse perder, y revise personalmente su cuenta
de exchange.

**Usted es responsable de su cuenta.** Ejecuta el conector en su ordenador, con su cuenta
de exchange y sus claves API. Es responsable de mantener seguras esas claves y de cumplir
las leyes del lugar donde vive; algunos países restringen la operativa con derivados
apalancados, o la inversión con dinero prestado, para clientes minoristas.

**Características que usted acepta por separado.** El conector está diseñado para
funcionar así, lo que puede diferir de lo que usted esperaría de un software de trading.
El asistente de configuración le pide que acepte cada una de estas características con
un segundo sí, por separado:
- en un exchange de criptoactivos, actúa sobre cada señal una sola vez, cuando llega, y
  nunca repite una señal perdida mientras no estaba en funcionamiento o no estaba
  conectado; en Alpaca, aplica solo la cartera objetivo más reciente, mientras el mercado
  está abierto;
- un take-profit queda en el libro de órdenes como orden limitada y puede no ejecutarse;
- un stop-loss se dispara a mercado y puede ejecutarse a un precio peor que su precio de
  activación;
- cierra posiciones a mercado en los casos de la cláusula 8.3 de LICENSE.es, y en Alpaca
  las vende a mercado en los casos de la cláusula 8.5;
- en Alpaca, vende a mercado para seguir la cartera objetivo; compra lo que el feed
  compra en la apertura con una orden a mercado poco después de la apertura, a cualquier
  precio, y cualquier otra cantidad que le falte a la cuenta solo a un precio igual o
  inferior al precio límite que envía MarketAI, por lo que la cuenta puede mantener
  menos que su cartera objetivo;
- en Alpaca, trata como del bot todas las acciones que la cuenta mantiene en los mercados
  del bot, con independencia de quién las haya comprado;
- en Alpaca, un stop-loss solo se dispara mientras el mercado está abierto, y una fracción
  de acción lleva solo su stop-loss, válido durante una sesión, que se vuelve a colocar
  cada día mientras el conector está en funcionamiento;
- se actualiza solo, y una actualización puede cambiar su forma de operar.
