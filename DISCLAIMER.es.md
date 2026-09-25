# Advertencia de riesgos

Lea esto antes de usar el MarketAI Connector con dinero real. In English:
[DISCLAIMER.md](DISCLAIMER.md).

**Puede perder dinero, incluso más del que espera.** El conector opera con apalancamiento
en futuros perpetuos. Cuando el precio se mueve en contra de una posición apalancada,
usted pierde un múltiplo de ese movimiento: con apalancamiento 3x, un movimiento del 10 %
en su contra le hace perder alrededor del 30 % del dinero de esa posición. Con margen
cruzado, una pérdida suficientemente grande puede llevarse todo el saldo de su cuenta.

**Las señales no son asesoramiento personalizado.** Los feeds de señales de MarketAI
proceden de modelos estadísticos. Todos los que siguen un feed reciben las mismas
señales, sea cual sea su situación. No comprobamos si esta operativa es adecuada para
usted, para su patrimonio o para su experiencia. Las simulaciones sobre datos históricos
(backtests) y los resultados reales pasados no predicen los resultados futuros. Un feed
puede perder dinero durante largos periodos.

**Cada orden es suya.** Las señales proceden de MarketAI; la decisión de seguirlas
automáticamente es suya. Una vez que inicia el conector, este coloca, modifica y cancela
órdenes en su cuenta por sí solo, sin consultarle antes. Al ejecutarlo, usted autoriza
esas órdenes, que, junto con sus resultados, son suyas sea cual sea su causa. Si un fallo
del conector o del servicio de MarketAI le causa una pérdida, la cláusula 10 de
LICENSE.es establece si debemos indemnizarle: si usa el conector para un negocio, no,
salvo dolo o culpa grave; si es consumidor, sí, en los términos que establece la ley y en
ninguno más. Revise su cuenta de exchange con regularidad, y detenga el conector de
inmediato si ve una orden que no esperaba. Para que deje de operar, pause sus bots en My
bots, lo que cierra sus posiciones, o detenga el conector, lo que las deja abiertas con
su stop-loss y su take-profit.

**Las órdenes no siempre se ejecutan según lo previsto.** Un stop-loss se dispara como
orden a mercado y, en un mercado rápido, puede ejecutarse a un precio peor que su precio
de activación. Un take-profit queda en el libro de órdenes como orden limitada y puede no
ejecutarse cuando el precio solo lo toca. Los exchanges, las redes, MarketAI y su propio
ordenador pueden fallar o funcionar con lentitud, y una señal enviada mientras el
conector está desconectado no se vuelve a enviar.

**Algunos cambios en MarketAI cierran sus posiciones.** Cuando su bot está en pausa,
pendiente de aprobación por MarketAI o impagado, cuando se retira su feed de señales, y
cuando MarketAI comunica un estado que el conector no reconoce, el conector cierra todas
las posiciones abiertas (a mercado cuando una orden limitada no se ejecuta) y después
espera. Cuando usted cambia un bot a otro feed de señales, el conector cierra primero las
posiciones del feed anterior. Un cierre puede materializar una pérdida. Por ejemplo:
tiene una posición larga en BTC con apalancamiento 3x y su pago falla cuando BTC está un
5 % por debajo de su precio de entrada. El conector cierra a mercado y usted pierde
alrededor del 15 % del dinero de esa posición, más las comisiones. Cuando el bot se
elimina o se sustituye su token, el conector deja de operar y mantiene las posiciones
abiertas tal como están, cada una con el stop-loss ya colocado en el exchange.

**El conector se actualiza solo.** Una nueva versión se instala automáticamente,
normalmente en menos de un cuarto de hora, salvo que usted desactive las actualizaciones
automáticas. Una nueva versión puede cambiar el comportamiento del conector. Lo que
cambia cada versión está en las notas de versión:
https://github.com/sergimes/marketai-connector/releases.

**El software puede tener errores.** Se proporciona tal cual: véanse las cláusulas 9 y
10 de [LICENSE.es](LICENSE.es), que también indican qué derechos conserva como
consumidor. Use una clave API que **no pueda retirar fondos**, empiece con una **cuenta
demo** y después con una cantidad que pueda permitirse perder, y revise personalmente su
cuenta de exchange.

**Usted es responsable de su cuenta.** Ejecuta el conector en su ordenador, con su cuenta
de exchange y sus claves API. Es responsable de mantener seguras esas claves y de cumplir
las leyes del lugar donde vive; algunos países restringen la operativa con derivados
apalancados para clientes minoristas.

**Características que usted acepta por separado.** El conector está diseñado para
funcionar así, lo que puede diferir de lo que usted esperaría de un software de trading.
El asistente de configuración le pide que acepte cada una de estas características con
un segundo sí, por separado:
- actúa sobre cada señal una sola vez, cuando llega, y nunca repite una señal perdida
  mientras no estaba en funcionamiento o no estaba conectado;
- un take-profit queda en el libro de órdenes como orden limitada y puede no ejecutarse;
- un stop-loss se dispara a mercado y puede ejecutarse a un precio peor que su precio de
  activación;
- cierra posiciones a mercado en los casos de la cláusula 8.3 de LICENSE.es;
- se actualiza solo, y una actualización puede cambiar su forma de operar.
