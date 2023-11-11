
// SoftI2C macros (PORTB 3 is SDA, PORTB 4 is SCL)
#define SCL_PIN  4
#define SDA_PIN  3
#define SCL_HIGH() (PORTB |= (1 << SCL_PIN))
#define SCL_LOW()  (PORTB &= ~(1 << SCL_PIN))
#define SDA_HIGH() (PORTB |= (1 << SDA_PIN))
#define SDA_LOW()  (PORTB &= ~(1 << SDA_PIN))
#define SDA_READ() ((PORTB >> SDA_PIN) & 1)
#define SCL_READ() ((PORTB >> SCL_PIN) & 1)
#define SDA_INPUT()  (TRISB |= (1 << SDA_PIN))
#define SDA_OUTPUT() (TRISB &= ~(1 << SDA_PIN))