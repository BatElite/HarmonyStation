//check defines/access.dm for access levels! this is just airlock specific stuff, and access is used for some consoles too
//States for access_control
#define ACCESS_STATE_INTERNAL	-1
#define ACCESS_STATE_LOCKED		0
#define ACCESS_STATE_EXTERNAL	1
//States for airlock_control
#define AIRLOCK_STATE_INOPEN		-2
#define AIRLOCK_STATE_PRESSURIZE	-1
#define AIRLOCK_STATE_CLOSED		0
#define AIRLOCK_STATE_DEPRESSURIZE	1
#define AIRLOCK_STATE_OUTOPEN		2

#define AIRLOCK_CONTROL_RANGE 5

#define AIRLOCK_WIRE_IDSCAN 1
#define AIRLOCK_WIRE_MAIN_POWER1 2
#define AIRLOCK_WIRE_MAIN_POWER2 3
#define AIRLOCK_WIRE_DOOR_BOLTS 4
#define AIRLOCK_WIRE_BACKUP_POWER1 5
#define AIRLOCK_WIRE_BACKUP_POWER2 6
#define AIRLOCK_WIRE_OPEN_DOOR 7
#define AIRLOCK_WIRE_AI_CONTROL 8
#define AIRLOCK_WIRE_ELECTRIFY 9
#define AIRLOCK_WIRE_SAFETY 10
