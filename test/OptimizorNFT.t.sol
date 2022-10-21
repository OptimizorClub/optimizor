// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.15;

import "./BaseTest.sol";
import "../src/OptimizorNFT.sol";
import "../src/DataHelpers.sol";
import "./CommitHash.sol";

uint constant SALT = 0;

contract OptimizorTest is BaseTest {
    function run() external returns (string memory) {
        setUp();
        testCheapExpensiveSqrt();
        uint tokenId = (SQRT_ID << 32) | 2;
        return opt.tokenURI(tokenId);
    }

    function testCheapSqrt() public {
        addSqrtChallenge();

        testChallenger(
            SQRT_ID,
            address(cheapSqrt),
            address(cheapSqrt).codehash
        );
    }

    function testExpensiveSqrt() public {
        addSqrtChallenge();

        testChallenger(
            SQRT_ID,
            address(expSqrt),
            address(expSqrt).codehash
        );
    }

    function testCheapExpensiveSqrt() public {
        addSqrtChallenge();

        testChallengers(
            SQRT_ID,
            address(expSqrt),
            address(expSqrt).codehash,
            address(cheapSqrt),
            address(cheapSqrt).codehash
        );
    }

    function testCheapSum() public {
        addSumChallenge();

        testChallenger(
            SUM_ID,
            address(cheapSum),
            address(cheapSum).codehash
        );
    }

    function testExpensiveSum() public {
        addSumChallenge();

        testChallenger(
            SUM_ID,
            address(expSum),
            address(expSum).codehash
        );
    }

    function testCheapExpensiveSum() public {
        addSumChallenge();

        testChallengers(
            SUM_ID,
            address(expSum),
            address(expSum).codehash,
            address(cheapSum),
            address(cheapSum).codehash
        );
    }

    function testCheapSqrtNFT() public {
        addSqrtChallenge();

        testChallenger(
            SQRT_ID,
            address(cheapSqrt),
            address(cheapSqrt).codehash
        );

        assertEq(opt.tokenURI((SQRT_ID << 32) | 0), "data:application/json;base64,eyJuYW1lIjoiIE9wdGltaXpvciBDbHViOiBTUVJUIiwgImRlc2NyaXB0aW9uIjoiQXJ0OiBTcGlyYWwgb2YgVGhlb2RvcnVzLlxuTGVhZGVyYm9hcmQ6XG4xLiAweGI0Yzc5ZGFiOGYyNTljN2FlZTZlNWIyYWE3Mjk4MjE4NjQyMjdlODQiLCAiYXR0cmlidXRlcyI6IFt7ICJ0cmFpdF90eXBlIjogIkxlYWRlciIsICJ2YWx1ZSI6ICJObyJ9LCB7ICJ0cmFpdF90eXBlIjogIlRvcCAzIiwgInZhbHVlIjogIlllcyJ9LCB7ICJ0cmFpdF90eXBlIjogIlRvcCAxMCIsICJ2YWx1ZSI6ICJZZXMifSBdLCJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUIzYVdSMGFEMGlNamt3SWlCb1pXbG5hSFE5SWpVd01DSWdkbWxsZDBKdmVEMGlNQ0F3SURJNU1DQTFNREFpSUhodGJHNXpQU0pvZEhSd09pOHZkM2QzTG5jekxtOXlaeTh5TURBd0wzTjJaeUlnZUcxc2JuTTZlR3hwYm1zOUoyaDBkSEE2THk5M2QzY3Vkek11YjNKbkx6RTVPVGt2ZUd4cGJtc25QanhrWldaelBqeG1hV3gwWlhJZ2FXUTlJbVl4SWo0OFptVkpiV0ZuWlNCeVpYTjFiSFE5SW5Bd0lpQjRiR2x1YXpwb2NtVm1QU0prWVhSaE9tbHRZV2RsTDNOMlp5dDRiV3c3WW1GelpUWTBMRkJJVGpKYWVVSXpZVmRTTUdGRU1HNU5hbXQzU25sQ2IxcFhiRzVoU0ZFNVNucFZkMDFEWTJka2JXeHNaREJLZG1WRU1HNU5RMEYzU1VSSk5VMURRVEZOUkVGdVNVaG9kR0pITlhwUVUyUnZaRWhTZDA5cE9IWmtNMlF6VEc1amVreHRPWGxhZVRoNVRVUkJkMHd6VGpKYWVXTXJVRWhLYkZrelVXZGtNbXhyWkVkbk9VcDZTVFZOU0VJMFNubENiMXBYYkc1aFNGRTVTbnBWZDAxSVFqUktlVUp0WVZkNGMxQlRZMnBhYWxab1RXMWFiRXA1T0N0UVF6bDZaRzFqS3lJdlBpQThabVZKYldGblpTQnlaWE4xYkhROUluQXhJaUI0YkdsdWF6cG9jbVZtUFNKa1lYUmhPbWx0WVdkbEwzTjJaeXQ0Yld3N1ltRnpaVFkwTEZCSVRqSmFlVUl6WVZkU01HRkVNRzVOYW10M1NubENiMXBYYkc1aFNGRTVTbnBWZDAxRFkyZGtiV3hzWkRCS2RtVkVNRzVOUTBGM1NVUkpOVTFEUVRGTlJFRnVTVWhvZEdKSE5YcFFVMlJ2WkVoU2QwOXBPSFprTTJRelRHNWpla3h0T1hsYWVUaDVUVVJCZDB3elRqSmFlV01yVUVkT2NHTnRUbk5hVTBKcVpVUXdiazlVV1c1SlIwNDFVRk5qZUUxRVFXNUpTRWs1U25wRmVVMUlRalJLZVVKdFlWZDRjMUJUWTJwTlJFRjNUVVJCZDBwNU9DdFFRemw2Wkcxakt5SXZQaUE4Wm1WSmJXRm5aU0J5WlhOMWJIUTlJbkF5SWlCNGJHbHVhenBvY21WbVBTSmtZWFJoT21sdFlXZGxMM04yWnl0NGJXdzdZbUZ6WlRZMExGQklUakphZVVJellWZFNNR0ZFTUc1TmFtdDNTbmxDYjFwWGJHNWhTRkU1U25wVmQwMURZMmRrYld4c1pEQktkbVZFTUc1TlEwRjNTVVJKTlUxRFFURk5SRUZ1U1Vob2RHSkhOWHBRVTJSdlpFaFNkMDlwT0haa00yUXpURzVqZWt4dE9YbGFlVGg1VFVSQmQwd3pUakphZVdNclVFZE9jR050VG5OYVUwSnFaVVF3YmsxcVJUTktlVUpxWlZRd2JrMVVRWGRLZVVKNVVGTmplRTFxUW5kbFEyTm5XbTFzYzJKRU1HNUpla1V3VFZSTk5FMXBZM1pRYW5kMll6TmFibEJuUFQwaUlDOCtQR1psU1cxaFoyVWdjbVZ6ZFd4MFBTSndNeUlnZUd4cGJtczZhSEpsWmowaVpHRjBZVHBwYldGblpTOXpkbWNyZUcxc08ySmhjMlUyTkN4UVNFNHlXbmxDTTJGWFVqQmhSREJ1VFdwcmQwcDVRbTlhVjJ4dVlVaFJPVXA2VlhkTlEyTm5aRzFzYkdRd1NuWmxSREJ1VFVOQmQwbEVTVFZOUTBFeFRVUkJia2xJYUhSaVJ6VjZVRk5rYjJSSVVuZFBhVGgyWkROa00weHVZM3BNYlRsNVduazRlVTFFUVhkTU0wNHlXbmxqSzFCSFRuQmpiVTV6V2xOQ2FtVkVNRzVOYWtFMVNubENhbVZVTUc1TlZFRjNTbmxDZVZCVFkzaE5SRUozWlVOaloxcHRiSE5pUkRCdVNYcEJkMDFFUVhkTlEyTjJVR3AzZG1NeldtNVFaejA5SWlBdlBqeG1aVUpzWlc1a0lHMXZaR1U5SW05MlpYSnNZWGtpSUdsdVBTSndNQ0lnYVc0eVBTSndNU0lnTHo0OFptVkNiR1Z1WkNCdGIyUmxQU0psZUdOc2RYTnBiMjRpSUdsdU1qMGljRElpSUM4K1BHWmxRbXhsYm1RZ2JXOWtaVDBpYjNabGNteGhlU0lnYVc0eVBTSndNeUlnY21WemRXeDBQU0ppYkdWdVpFOTFkQ0lnTHo0OFptVkhZWFZ6YzJsaGJrSnNkWElnYVc0OUltSnNaVzVrVDNWMElpQnpkR1JFWlhacFlYUnBiMjQ5SWpReUlpQXZQand2Wm1sc2RHVnlQaUE4WTJ4cGNGQmhkR2dnYVdROUltTnZjbTVsY25NaVBqeHlaV04wSUhkcFpIUm9QU0l5T1RBaUlHaGxhV2RvZEQwaU5UQXdJaUJ5ZUQwaU5ESWlJSEo1UFNJME1pSWdMejQ4TDJOc2FYQlFZWFJvUGp4d1lYUm9JR2xrUFNKMFpYaDBMWEJoZEdndFlTSWdaRDBpVFRRd0lERXlJRWd5TlRBZ1FUSTRJREk0SURBZ01DQXhJREkzT0NBME1DQldORFl3SUVFeU9DQXlPQ0F3SURBZ01TQXlOVEFnTkRnNElFZzBNQ0JCTWpnZ01qZ2dNQ0F3SURFZ01USWdORFl3SUZZME1DQkJNamdnTWpnZ01DQXdJREVnTkRBZ01USWdlaUlnTHo0OGNHRjBhQ0JwWkQwaWJXbHVhVzFoY0NJZ1pEMGlUVEl6TkNBME5EUkRNak0wSURRMU55NDVORGtnTWpReUxqSXhJRFEyTXlBeU5UTWdORFl6SWlBdlBqeG1hV3gwWlhJZ2FXUTlJblJ2Y0MxeVpXZHBiMjR0WW14MWNpSStQR1psUjJGMWMzTnBZVzVDYkhWeUlHbHVQU0pUYjNWeVkyVkhjbUZ3YUdsaklpQnpkR1JFWlhacFlYUnBiMjQ5SWpJMElpQXZQand2Wm1sc2RHVnlQanhzYVc1bFlYSkhjbUZrYVdWdWRDQnBaRDBpWjNKaFpDMTFjQ0lnZURFOUlqRWlJSGd5UFNJd0lpQjVNVDBpTVNJZ2VUSTlJakFpUGp4emRHOXdJRzltWm5ObGREMGlNQzR3SWlCemRHOXdMV052Ykc5eVBTSjNhR2wwWlNJZ2MzUnZjQzF2Y0dGamFYUjVQU0l4SWlBdlBqeHpkRzl3SUc5bVpuTmxkRDBpTGpraUlITjBiM0F0WTI5c2IzSTlJbmRvYVhSbElpQnpkRzl3TFc5d1lXTnBkSGs5SWpBaUlDOCtQQzlzYVc1bFlYSkhjbUZrYVdWdWRENDhiR2x1WldGeVIzSmhaR2xsYm5RZ2FXUTlJbWR5WVdRdFpHOTNiaUlnZURFOUlqQWlJSGd5UFNJeElpQjVNVDBpTUNJZ2VUSTlJakVpUGp4emRHOXdJRzltWm5ObGREMGlNQzR3SWlCemRHOXdMV052Ykc5eVBTSjNhR2wwWlNJZ2MzUnZjQzF2Y0dGamFYUjVQU0l4SWlBdlBqeHpkRzl3SUc5bVpuTmxkRDBpTUM0NUlpQnpkRzl3TFdOdmJHOXlQU0ozYUdsMFpTSWdjM1J2Y0MxdmNHRmphWFI1UFNJd0lpQXZQand2YkdsdVpXRnlSM0poWkdsbGJuUStQRzFoYzJzZ2FXUTlJbVpoWkdVdGRYQWlJRzFoYzJ0RGIyNTBaVzUwVlc1cGRITTlJbTlpYW1WamRFSnZkVzVrYVc1blFtOTRJajQ4Y21WamRDQjNhV1IwYUQwaU1TSWdhR1ZwWjJoMFBTSXhJaUJtYVd4c1BTSjFjbXdvSTJkeVlXUXRkWEFwSWlBdlBqd3ZiV0Z6YXo0OGJXRnpheUJwWkQwaVptRmtaUzFrYjNkdUlpQnRZWE5yUTI5dWRHVnVkRlZ1YVhSelBTSnZZbXBsWTNSQ2IzVnVaR2x1WjBKdmVDSStQSEpsWTNRZ2QybGtkR2c5SWpFaUlHaGxhV2RvZEQwaU1TSWdabWxzYkQwaWRYSnNLQ05uY21Ga0xXUnZkMjRwSWlBdlBqd3ZiV0Z6YXo0OGJXRnpheUJwWkQwaWJtOXVaU0lnYldGemEwTnZiblJsYm5SVmJtbDBjejBpYjJKcVpXTjBRbTkxYm1ScGJtZENiM2dpUGp4eVpXTjBJSGRwWkhSb1BTSXhJaUJvWldsbmFIUTlJakVpSUdacGJHdzlJbmRvYVhSbElpQXZQand2YldGemF6NDhiR2x1WldGeVIzSmhaR2xsYm5RZ2FXUTlJbWR5WVdRdGMzbHRZbTlzSWo0OGMzUnZjQ0J2Wm1aelpYUTlJakF1TnlJZ2MzUnZjQzFqYjJ4dmNqMGlkMmhwZEdVaUlITjBiM0F0YjNCaFkybDBlVDBpTVNJZ0x6NDhjM1J2Y0NCdlptWnpaWFE5SWk0NU5TSWdjM1J2Y0MxamIyeHZjajBpZDJocGRHVWlJSE4wYjNBdGIzQmhZMmwwZVQwaU1DSWdMejQ4TDJ4cGJtVmhja2R5WVdScFpXNTBQanh0WVhOcklHbGtQU0ptWVdSbExYTjViV0p2YkNJZ2JXRnphME52Ym5SbGJuUlZibWwwY3owaWRYTmxjbE53WVdObFQyNVZjMlVpUGp4eVpXTjBJSGRwWkhSb1BTSXlPVEJ3ZUNJZ2FHVnBaMmgwUFNJeU1EQndlQ0lnWm1sc2JEMGlkWEpzS0NObmNtRmtMWE41YldKdmJDa2lJQzgrUEM5dFlYTnJQand2WkdWbWN6NDhaeUJqYkdsd0xYQmhkR2c5SW5WeWJDZ2pZMjl5Ym1WeWN5a2lQanh5WldOMElHWnBiR3c5SW1ZMVlUSm1aU0lnZUQwaU1IQjRJaUI1UFNJd2NIZ2lJSGRwWkhSb1BTSXlPVEJ3ZUNJZ2FHVnBaMmgwUFNJMU1EQndlQ0lnTHo0OGNtVmpkQ0J6ZEhsc1pUMGlabWxzZEdWeU9pQjFjbXdvSTJZeEtTSWdlRDBpTUhCNElpQjVQU0l3Y0hnaUlIZHBaSFJvUFNJeU9UQndlQ0lnYUdWcFoyaDBQU0kxTURCd2VDSWdMejRnUEdjZ2MzUjViR1U5SW1acGJIUmxjanAxY213b0kzUnZjQzF5WldkcGIyNHRZbXgxY2lrN0lIUnlZVzV6Wm05eWJUcHpZMkZzWlNneExqVXBPeUIwY21GdWMyWnZjbTB0YjNKcFoybHVPbU5sYm5SbGNpQjBiM0E3SWo0OGNtVmpkQ0JtYVd4c1BTSnViMjVsSWlCNFBTSXdjSGdpSUhrOUlqQndlQ0lnZDJsa2RHZzlJakk1TUhCNElpQm9aV2xuYUhROUlqVXdNSEI0SWlBdlBqeGxiR3hwY0hObElHTjRQU0kxTUNVaUlHTjVQU0l3Y0hnaUlISjRQU0l4T0RCd2VDSWdjbms5SWpFeU1IQjRJaUJtYVd4c1BTSWpNREF3SWlCdmNHRmphWFI1UFNJd0xqZzFJaUF2UGp3dlp6NDhjbVZqZENCNFBTSXdJaUI1UFNJd0lpQjNhV1IwYUQwaU1qa3dJaUJvWldsbmFIUTlJalV3TUNJZ2NuZzlJalF5SWlCeWVUMGlORElpSUdacGJHdzlJbkpuWW1Fb01Dd3dMREFzTUNraUlITjBjbTlyWlQwaWNtZGlZU2d5TlRVc01qVTFMREkxTlN3d0xqSXBJaUF2UGp3dlp6NDhkR1Y0ZENCMFpYaDBMWEpsYm1SbGNtbHVaejBpYjNCMGFXMXBlbVZUY0dWbFpDSStQSFJsZUhSUVlYUm9JSE4wWVhKMFQyWm1jMlYwUFNJdE1UQXdKU0lnWm1sc2JEMGlkMmhwZEdVaUlHWnZiblF0Wm1GdGFXeDVQU0luUTI5MWNtbGxjaUJPWlhjbkxDQnRiMjV2YzNCaFkyVWlJR1p2Ym5RdGMybDZaVDBpTVRCd2VDSWdlR3hwYm1zNmFISmxaajBpSTNSbGVIUXRjR0YwYUMxaElqNVRVVkpVSU9LQW9pQXdlR1kxWVRKbVpUUTFaalJtTVRNd09EVXdNbUl4WXpFek5tSTVaV1k0WVdZeE16WXhOREV6T0RJZ1BHRnVhVzFoZEdVZ1lXUmthWFJwZG1VOUluTjFiU0lnWVhSMGNtbGlkWFJsVG1GdFpUMGljM1JoY25SUFptWnpaWFFpSUdaeWIyMDlJakFsSWlCMGJ6MGlNVEF3SlNJZ1ltVm5hVzQ5SWpCeklpQmtkWEk5SWpNd2N5SWdjbVZ3WldGMFEyOTFiblE5SW1sdVpHVm1hVzVwZEdVaUlDOCtQQzkwWlhoMFVHRjBhRDRnUEhSbGVIUlFZWFJvSUhOMFlYSjBUMlptYzJWMFBTSXdKU0lnWm1sc2JEMGlkMmhwZEdVaUlHWnZiblF0Wm1GdGFXeDVQU0luUTI5MWNtbGxjaUJPWlhjbkxDQnRiMjV2YzNCaFkyVWlJR1p2Ym5RdGMybDZaVDBpTVRCd2VDSWdlR3hwYm1zNmFISmxaajBpSTNSbGVIUXRjR0YwYUMxaElqNVRVVkpVSU9LQW9pQXdlR1kxWVRKbVpUUTFaalJtTVRNd09EVXdNbUl4WXpFek5tSTVaV1k0WVdZeE16WXhOREV6T0RJZ1BHRnVhVzFoZEdVZ1lXUmthWFJwZG1VOUluTjFiU0lnWVhSMGNtbGlkWFJsVG1GdFpUMGljM1JoY25SUFptWnpaWFFpSUdaeWIyMDlJakFsSWlCMGJ6MGlNVEF3SlNJZ1ltVm5hVzQ5SWpCeklpQmtkWEk5SWpNd2N5SWdjbVZ3WldGMFEyOTFiblE5SW1sdVpHVm1hVzVwZEdVaUlDOCtJRHd2ZEdWNGRGQmhkR2crUEhSbGVIUlFZWFJvSUhOMFlYSjBUMlptYzJWMFBTSTFNQ1VpSUdacGJHdzlJbmRvYVhSbElpQm1iMjUwTFdaaGJXbHNlVDBpSjBOdmRYSnBaWElnVG1WM0p5d2diVzl1YjNOd1lXTmxJaUJtYjI1MExYTnBlbVU5SWpFd2NIZ2lJSGhzYVc1ck9taHlaV1k5SWlOMFpYaDBMWEJoZEdndFlTSStUM0IwYVcxcGVtOXlJRU5zZFdJZzRvQ2lJREI0TURBd01EQXdNREF3TURBd01EQXdNREF3TURBd01EQXdNREF3TURBd01EQXdNREF3TURBd01DQThZVzVwYldGMFpTQmhaR1JwZEdsMlpUMGljM1Z0SWlCaGRIUnlhV0oxZEdWT1lXMWxQU0p6ZEdGeWRFOW1abk5sZENJZ1puSnZiVDBpTUNVaUlIUnZQU0l4TURBbElpQmlaV2RwYmowaU1ITWlJR1IxY2owaU16QnpJaUJ5WlhCbFlYUkRiM1Z1ZEQwaWFXNWtaV1pwYm1sMFpTSWdMejQ4TDNSbGVIUlFZWFJvUGp4MFpYaDBVR0YwYUNCemRHRnlkRTltWm5ObGREMGlMVFV3SlNJZ1ptbHNiRDBpZDJocGRHVWlJR1p2Ym5RdFptRnRhV3g1UFNJblEyOTFjbWxsY2lCT1pYY25MQ0J0YjI1dmMzQmhZMlVpSUdadmJuUXRjMmw2WlQwaU1UQndlQ0lnZUd4cGJtczZhSEpsWmowaUkzUmxlSFF0Y0dGMGFDMWhJajVQY0hScGJXbDZiM0lnUTJ4MVlpRGlnS0lnTUhnd01EQXdNREF3TURBd01EQXdNREF3TURBd01EQXdNREF3TURBd01EQXdNREF3TURBd01EQXdJRHhoYm1sdFlYUmxJR0ZrWkdsMGFYWmxQU0p6ZFcwaUlHRjBkSEpwWW5WMFpVNWhiV1U5SW5OMFlYSjBUMlptYzJWMElpQm1jbTl0UFNJd0pTSWdkRzg5SWpFd01DVWlJR0psWjJsdVBTSXdjeUlnWkhWeVBTSXpNSE1pSUhKbGNHVmhkRU52ZFc1MFBTSnBibVJsWm1sdWFYUmxJaUF2UGp3dmRHVjRkRkJoZEdnK1BDOTBaWGgwUGp4bklHMWhjMnM5SW5WeWJDZ2pabUZrWlMxemVXMWliMndwSWo0OGNtVmpkQ0JtYVd4c1BTSnViMjVsSWlCNFBTSXdjSGdpSUhrOUlqQndlQ0lnZDJsa2RHZzlJakk1TUhCNElpQm9aV2xuYUhROUlqSXdNSEI0SWlBdlBpQThkR1Y0ZENCNVBTSTNNSEI0SWlCNFBTSXpNbkI0SWlCbWFXeHNQU0ozYUdsMFpTSWdabTl1ZEMxbVlXMXBiSGs5SWlkRGIzVnlhV1Z5SUU1bGR5Y3NJRzF2Ym05emNHRmpaU0lnWm05dWRDMTNaV2xuYUhROUlqSXdNQ0lnWm05dWRDMXphWHBsUFNJek5uQjRJajVUVVZKVVBDOTBaWGgwUGp4MFpYaDBJSGs5SWpFeE5YQjRJaUI0UFNJek1uQjRJaUJtYVd4c1BTSjNhR2wwWlNJZ1ptOXVkQzFtWVcxcGJIazlJaWREYjNWeWFXVnlJRTVsZHljc0lHMXZibTl6Y0dGalpTSWdabTl1ZEMxM1pXbG5hSFE5SWpJd01DSWdabTl1ZEMxemFYcGxQU0l5TUhCNElqNVNZVzVySUNNeUx6RThMM1JsZUhRK1BDOW5Qanh5WldOMElIZzlJakUySWlCNVBTSXhOaUlnZDJsa2RHZzlJakkxT0NJZ2FHVnBaMmgwUFNJME5qZ2lJSEo0UFNJeU5pSWdjbms5SWpJMklpQm1hV3hzUFNKeVoySmhLREFzTUN3d0xEQXBJaUJ6ZEhKdmEyVTlJbkpuWW1Fb01qVTFMREkxTlN3eU5UVXNNQzR5S1NJZ0x6NDhaeUJ0WVhOclBTSjFjbXdvSTI1dmJtVXBJaUJ6ZEhsc1pUMGlkSEpoYm5ObWIzSnRPblJ5WVc1emJHRjBaU2d6TUhCNExERXpNSEI0S1NJK1BISmxZM1FnZDJsa2RHZzlJakl6TUNJZ2FHVnBaMmgwUFNJeU16QWlJSEo0UFNJeE9IQjRJaUJ5ZVQwaU1UaHdlQ0lnWm1sc2JEMGljbWRpWVNnd0xEQXNNQ3d3TGpFcElpQXZQand2Wno0Z1BHY2djM1I1YkdVOUluUnlZVzV6Wm05eWJUcDBjbUZ1YzJ4aGRHVW9Namx3ZUN3Z016ZzBjSGdwSWo0OGNtVmpkQ0IzYVdSMGFEMGlNVE16Y0hnaUlHaGxhV2RvZEQwaU1qWndlQ0lnY25nOUlqaHdlQ0lnY25rOUlqaHdlQ0lnWm1sc2JEMGljbWRpWVNnd0xEQXNNQ3d3TGpZcElpQXZQangwWlhoMElIZzlJakV5Y0hnaUlIazlJakUzY0hnaUlHWnZiblF0Wm1GdGFXeDVQU0luUTI5MWNtbGxjaUJPWlhjbkxDQnRiMjV2YzNCaFkyVWlJR1p2Ym5RdGMybDZaVDBpTVRKd2VDSWdabWxzYkQwaWQyaHBkR1VpUGp4MGMzQmhiaUJtYVd4c1BTSnlaMkpoS0RJMU5Td3lOVFVzTWpVMUxEQXVOaWtpUGtsRU9pQThMM1J6Y0dGdVBqRTNNVGM1T0RZNU1UZzBQQzkwWlhoMFBqd3ZaejRnUEdjZ2MzUjViR1U5SW5SeVlXNXpabTl5YlRwMGNtRnVjMnhoZEdVb01qbHdlQ3dnTkRFMGNIZ3BJajQ4Y21WamRDQjNhV1IwYUQwaU1UQTFjSGdpSUdobGFXZG9kRDBpTWpad2VDSWdjbmc5SWpod2VDSWdjbms5SWpod2VDSWdabWxzYkQwaWNtZGlZU2d3TERBc01Dd3dMallwSWlBdlBqeDBaWGgwSUhnOUlqRXljSGdpSUhrOUlqRTNjSGdpSUdadmJuUXRabUZ0YVd4NVBTSW5RMjkxY21sbGNpQk9aWGNuTENCdGIyNXZjM0JoWTJVaUlHWnZiblF0YzJsNlpUMGlNVEp3ZUNJZ1ptbHNiRDBpZDJocGRHVWlQangwYzNCaGJpQm1hV3hzUFNKeVoySmhLREkxTlN3eU5UVXNNalUxTERBdU5pa2lQa2RoY3lCMWMyVmtPaUE4TDNSemNHRnVQakE4TDNSbGVIUStQQzluUGlBOFp5QnpkSGxzWlQwaWRISmhibk5tYjNKdE9uUnlZVzV6YkdGMFpTZ3lPWEI0TENBME5EUndlQ2tpUGp4eVpXTjBJSGRwWkhSb1BTSXhNVEp3ZUNJZ2FHVnBaMmgwUFNJeU5uQjRJaUJ5ZUQwaU9IQjRJaUJ5ZVQwaU9IQjRJaUJtYVd4c1BTSnlaMkpoS0RBc01Dd3dMREF1TmlraUlDOCtQSFJsZUhRZ2VEMGlNVEp3ZUNJZ2VUMGlNVGR3ZUNJZ1ptOXVkQzFtWVcxcGJIazlJaWREYjNWeWFXVnlJRTVsZHljc0lHMXZibTl6Y0dGalpTSWdabTl1ZEMxemFYcGxQU0l4TW5CNElpQm1hV3hzUFNKM2FHbDBaU0krUEhSemNHRnVJR1pwYkd3OUluSm5ZbUVvTWpVMUxESTFOU3d5TlRVc01DNDJLU0krUjJGeklHOXdkR2s2SUR3dmRITndZVzQrT1RrbFBDOTBaWGgwUGp3dlp6NDhMM04yWno0PSJ9");
    }

    function testChallengers(
        uint CHL_ID,
        address challenger_0,
        bytes32 chl_hash_0,
        address challenger_1,
        bytes32 chl_hash_1
    ) internal {
        address other = address(42);
        vm.prank(other);
        opt.commit(computeKey(other, chl_hash_0, SALT));
        vm.stopPrank();

        opt.commit(computeKey(address(this), chl_hash_1, SALT));

        advancePeriod();

        (, uint32 preLevel) = opt.challenges(CHL_ID);

        vm.prank(other);
        opt.challenge(CHL_ID, challenger_0, other, SALT);
        vm.stopPrank();

        (, uint32 postLevel) = opt.challenges(CHL_ID);
        (, address postOpt, ) = opt.extraDetails(packTokenId(CHL_ID, postLevel));
        assertEq(postOpt, other);
        assertEq(postLevel, preLevel + 1);

        uint tokenId = (CHL_ID << 32) | postLevel;
        assertEq(opt.ownerOf(tokenId), other);

        address[] memory leaders = opt.leaderboard(tokenId);
        assertEq(leaders.length, 1);
        assertEq(leaders[0], other);

        opt.challenge(CHL_ID, challenger_1, address(this), SALT);
        (, uint32 postLevel2) = opt.challenges(CHL_ID);
        (, address postOpt2, ) = opt.extraDetails(packTokenId(CHL_ID, postLevel2));
        assertEq(postOpt2, address(this));
        assertEq(postLevel2, postLevel + 1);

        uint tokenId2 = (CHL_ID << 32) | postLevel2;
        assertEq(opt.ownerOf(tokenId2), address(this));

        vm.prank(other);
        vm.expectRevert(abi.encodeWithSignature("NotOptimizor()"));
        opt.challenge(CHL_ID, challenger_0, other, SALT);
        vm.stopPrank();

        address[] memory leaders2 = opt.leaderboard(tokenId2);
        assertEq(leaders2.length, 2);
        assertEq(leaders2[0], other);
        assertEq(leaders2[1], address(this));
    }

    // TODO make this function public too to fuzz it
    function testChallenger(uint CHL_ID, address challenger, bytes32 chl_hash) internal {
        opt.commit(computeKey(address(this), chl_hash, SALT));
        advancePeriod();

        (, uint32 preLevel) = opt.challenges(CHL_ID);
        opt.challenge(CHL_ID, challenger, address(this), SALT);
        (, uint32 postLevel) = opt.challenges(CHL_ID);
        (, address postOpt, ) = opt.extraDetails(packTokenId(CHL_ID, postLevel));
        assertEq(postOpt, address(this));
        assertEq(postLevel, preLevel + 1);

        uint tokenId = (CHL_ID << 32) | postLevel;
        assertEq(opt.ownerOf(tokenId), address(this));

        address[] memory leaders = opt.leaderboard(tokenId);
        assertEq(leaders.length, 1);
        assertEq(leaders[0], address(this));
    }
}
