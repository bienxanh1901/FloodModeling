      MODULE REACH_MOD
      USE datetime_module
      USE GATE_MOD
      IMPLICIT NONE

      PUBLIC :: REACH_TYPE
      PUBLIC :: REACH_PTR

      TYPE REACH_TYPE

        CHARACTER(100) :: NAME
        !Level
        INTEGER :: LEVEL = 0
        !Routing method
        INTEGER :: ROUTE
        !Parameter for Muskingum method
        REAL(8) :: K, X
        !Loss/gain
        REAL(8) :: LOSS_VALUE, LOSS_RATIO
        !Output
        REAL(8), ALLOCATABLE, DIMENSION(:) :: INFLOW, OUTFLOW
        !Downstream
        CHARACTER(100) :: DOWNSTREAM



        CONTAINS

        PROCEDURE,PASS(SEFT), PUBLIC :: SET_ROUTE_PARAM
        PROCEDURE,PASS(SEFT), PUBLIC :: RCHALLOCATING
        PROCEDURE,PASS(SEFT), PUBLIC :: REACH_ROUTING
        PROCEDURE,PASS(SEFT), PUBLIC :: MUSKINGUM_CALC

      END TYPE REACH_TYPE

      TYPE REACH_PTR
        !POINTER
        TYPE(REACH_TYPE), POINTER :: REACH
      END TYPE REACH_PTR

      INTERFACE REACH_TYPE
       MODULE PROCEDURE :: REACH_TYPE_CONSTRUCTOR
      END INTERFACE REACH_TYPE

      CONTAINS

        !Constructor
        PURE ELEMENTAL TYPE(REACH_TYPE) FUNCTION REACH_TYPE_CONSTRUCTOR(NAME, DOWNSTREAM)
        IMPLICIT NONE
        CHARACTER(*), INTENT(IN) :: NAME, DOWNSTREAM


        REACH_TYPE_CONSTRUCTOR%NAME = TRIM(NAME)
        REACH_TYPE_CONSTRUCTOR%DOWNSTREAM = TRIM(DOWNSTREAM)

        END FUNCTION REACH_TYPE_CONSTRUCTOR

        !Set parameter for REACH routing
        PURE ELEMENTAL SUBROUTINE SET_ROUTE_PARAM(SEFT, METHOD, LOSS_RATIO, LOSS_VALUE, K, X)

            CLASS(REACH_TYPE), INTENT(INOUT) :: SEFT
            INTEGER, INTENT(IN) :: METHOD
            REAL(8), INTENT(IN) :: LOSS_RATIO, LOSS_VALUE, K, X

            SEFT%ROUTE = METHOD
            SEFT%LOSS_RATIO = LOSS_RATIO
            SEFT%LOSS_VALUE = LOSS_VALUE
            IF(METHOD.EQ.MUSKINGUM_METHOD) THEN

                SEFT%K = K*3600.0D0
                SEFT%X = X

            ENDIF

        END SUBROUTINE SET_ROUTE_PARAM



        SUBROUTINE RCHALLOCATING(SEFT)

        CLASS(REACH_TYPE), INTENT(INOUT) :: SEFT
        INTEGER :: IERR

        ALLOCATE(SEFT%INFLOW(0:NTIME - 1), STAT = IERR)
        CALL ChkMemErr('REACH INFLOW', IERR)
        ALLOCATE(SEFT%OUTFLOW(0:NTIME - 1), STAT = IERR)
        CALL ChkMemErr('REACH OUTFLOW', IERR)
        SEFT%INFLOW = 0.0D0
        SEFT%OUTFLOW = 0.0D0

        END SUBROUTINE RCHALLOCATING

        INCLUDE "REACH_ROUTING.f"
      END MODULE REACH_MOD


      MODULE REACH_PTR_LIST_MOD
      USE REACH_MOD

#define LIST_DATA REACH_PTR
#include "linkedlist.f90"
#undef LIST_DATA

      END MODULE REACH_PTR_LIST_MOD