      SUBROUTINE GET_BASE_FLOW(SBS, ITER)
      USE PARAM
      USE CONSTANTS
      IMPLICIT NONE
      TYPE(SUBBASIN_TYPE), POINTER :: SBS
      INTEGER, INTENT(IN) :: ITER

      IF(SBS%BASE_FLOW_TYPE.EQ.CONSTANT_DATA) THEN

        SBS%BASE_FLOW(ITER) = SBS%BF_CONST

      ELSEIF(SBS%BASE_FLOW_TYPE.EQ.MONTHLY_DATA) THEN
* TODO (haipt#1#15/11/2017): FIND BASE FLOW BY MONTH

      ENDIF

      RETURN
      END SUBROUTINE GET_BASE_FLOW
