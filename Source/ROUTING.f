      SUBROUTINE ROUTING_CALC(SEFT)
      IMPLICIT NONE
      CLASS(BASIN_TYPE), INTENT(INOUT) :: SEFT
      TYPE(RESERVOIR_TYPE), POINTER :: RES
      TYPE(REACH_TYPE), POINTER :: RCH
      INTEGER :: J, K

      DO K = SEFT%MAX_LEVEL, 0, -1

        DO J = 1,SEFT%NREACH

            RCH => SEFT%REACH(J)
            IF(RCH%LEVEL.NE.K) CYCLE
            CALL SEFT%GET_REACH_INFLOW(RCH)
            IF(RCH%ROUTE.EQ.0) THEN

                RCH%OUTFLOW(CURRENT_IDX) = RCH%INFLOW(CURRENT_IDX)

            ELSE

                CALL RCH%REACH_ROUTING

            ENDIF

        ENDDO

        DO J = 1,SEFT%NRESERVOIR

            RES => SEFT%RESERVOIR(J)
            IF(RES%LEVEL.NE.K) CYCLE

            IF(SIMULATION_MODE.EQ.REAL_TIME_MODE.AND.
     &         ACTIVE_MODE.EQ.EXACTLY_CALC_MODE.AND.
     &         ASSOCIATED(RES%ZOBS)) THEN
               CALL RES%CORRECT_DATA_CURRENT_TIME
            ELSE
                CALL SEFT%GET_RESERVOIR_INFLOW(RES)
                IF(RES%ROUTE.EQ.0) CYCLE
                CALL RES%RESERVOIR_ROUTING
            ENDIF

        ENDDO

      ENDDO



      RETURN
      END SUBROUTINE ROUTING_CALC
