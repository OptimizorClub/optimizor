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

        assertEq(opt.tokenURI((SQRT_ID << 32) | 0), "data:application/json;base64,eyJuYW1lIjoiVGVzdE5hbWUiLCAiZGVzY3JpcHRpb24iOiJBcnQ6IFNwaXJhbCBvZiBUaGVvZG9ydXMuXG5MZWFkZXJib2FyZDpcbjEuIDB4YjRjNzlkYWI4ZjI1OWM3YWVlNmU1YjJhYTcyOTgyMTg2NDIyN2U4NCIsICJhdHRyaWJ1dGVzIjogW3sgInRyYWl0X3R5cGUiOiAiTGVhZGVyIiwgInZhbHVlIjogIk5vIn0sIHsgInRyYWl0X3R5cGUiOiAiVG9wIDMiLCAidmFsdWUiOiAiWWVzIn0sIHsgInRyYWl0X3R5cGUiOiAiVG9wIDEwIiwgInZhbHVlIjogIlllcyJ9IF0sImltYWdlIjogImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjNhV1IwYUQwaU1qa3dJaUJvWldsbmFIUTlJalV3TUNJZ2RtbGxkMEp2ZUQwaU1DQXdJREk1TUNBMU1EQWlJSGh0Ykc1elBTSm9kSFJ3T2k4dmQzZDNMbmN6TG05eVp5OHlNREF3TDNOMlp5SWdlRzFzYm5NNmVHeHBibXM5SjJoMGRIQTZMeTkzZDNjdWR6TXViM0puTHpFNU9Ua3ZlR3hwYm1zblBqeGtaV1p6UGp4bWFXeDBaWElnYVdROUltWXhJajQ4Wm1WSmJXRm5aU0J5WlhOMWJIUTlJbkF3SWlCNGJHbHVhenBvY21WbVBTSmtZWFJoT21sdFlXZGxMM04yWnl0NGJXdzdZbUZ6WlRZMExGQklUakphZVVJellWZFNNR0ZFTUc1TmFtdDNTbmxDYjFwWGJHNWhTRkU1U25wVmQwMURZMmRrYld4c1pEQktkbVZFTUc1TlEwRjNTVVJKTlUxRFFURk5SRUZ1U1Vob2RHSkhOWHBRVTJSdlpFaFNkMDlwT0haa00yUXpURzVqZWt4dE9YbGFlVGg1VFVSQmQwd3pUakphZVdNclVFaEtiRmt6VVdka01teHJaRWRuT1VwNlNUVk5TRUkwU25sQ2IxcFhiRzVoU0ZFNVNucFZkMDFJUWpSS2VVSnRZVmQ0YzFCVFkycGFhbFpvVFcxYWJFcDVPQ3RRUXpsNlpHMWpLeUl2UGlBOFptVkpiV0ZuWlNCeVpYTjFiSFE5SW5BeElpQjRiR2x1YXpwb2NtVm1QU0prWVhSaE9tbHRZV2RsTDNOMlp5dDRiV3c3WW1GelpUWTBMRkJJVGpKYWVVSXpZVmRTTUdGRU1HNU5hbXQzU25sQ2IxcFhiRzVoU0ZFNVNucFZkMDFEWTJka2JXeHNaREJLZG1WRU1HNU5RMEYzU1VSSk5VMURRVEZOUkVGdVNVaG9kR0pITlhwUVUyUnZaRWhTZDA5cE9IWmtNMlF6VEc1amVreHRPWGxhZVRoNVRVUkJkMHd6VGpKYWVXTXJVRWRPY0dOdFRuTmFVMEpxWlVRd2JrOVVXVzVKUjA0MVVGTmplRTFFUVc1SlNFazVTbnBGZVUxSVFqUktlVUp0WVZkNGMxQlRZMnBOUkVGM1RVUkJkMHA1T0N0UVF6bDZaRzFqS3lJdlBpQThabVZKYldGblpTQnlaWE4xYkhROUluQXlJaUI0YkdsdWF6cG9jbVZtUFNKa1lYUmhPbWx0WVdkbEwzTjJaeXQ0Yld3N1ltRnpaVFkwTEZCSVRqSmFlVUl6WVZkU01HRkVNRzVOYW10M1NubENiMXBYYkc1aFNGRTVTbnBWZDAxRFkyZGtiV3hzWkRCS2RtVkVNRzVOUTBGM1NVUkpOVTFEUVRGTlJFRnVTVWhvZEdKSE5YcFFVMlJ2WkVoU2QwOXBPSFprTTJRelRHNWpla3h0T1hsYWVUaDVUVVJCZDB3elRqSmFlV01yVUVkT2NHTnRUbk5hVTBKcVpVUXdiazFxUlROS2VVSnFaVlF3YmsxVVFYZEtlVUo1VUZOamVFMXFRbmRsUTJObldtMXNjMkpFTUc1SmVrVXdUVlJOTkUxcFkzWlFhbmQyWXpOYWJsQm5QVDBpSUM4K1BHWmxTVzFoWjJVZ2NtVnpkV3gwUFNKd015SWdlR3hwYm1zNmFISmxaajBpWkdGMFlUcHBiV0ZuWlM5emRtY3JlRzFzTzJKaGMyVTJOQ3hRU0U0eVdubENNMkZYVWpCaFJEQnVUV3ByZDBwNVFtOWFWMnh1WVVoUk9VcDZWWGROUTJOblpHMXNiR1F3U25abFJEQnVUVU5CZDBsRVNUVk5RMEV4VFVSQmJrbElhSFJpUnpWNlVGTmtiMlJJVW5kUGFUaDJaRE5rTTB4dVkzcE1iVGw1V25rNGVVMUVRWGRNTTA0eVdubGpLMUJIVG5CamJVNXpXbE5DYW1WRU1HNU5ha0UxU25sQ2FtVlVNRzVOVkVGM1NubENlVkJUWTNoTlJFSjNaVU5qWjFwdGJITmlSREJ1U1hwQmQwMUVRWGROUTJOMlVHcDNkbU16V201UVp6MDlJaUF2UGp4bVpVSnNaVzVrSUcxdlpHVTlJbTkyWlhKc1lYa2lJR2x1UFNKd01DSWdhVzR5UFNKd01TSWdMejQ4Wm1WQ2JHVnVaQ0J0YjJSbFBTSmxlR05zZFhOcGIyNGlJR2x1TWowaWNESWlJQzgrUEdabFFteGxibVFnYlc5a1pUMGliM1psY214aGVTSWdhVzR5UFNKd015SWdjbVZ6ZFd4MFBTSmliR1Z1WkU5MWRDSWdMejQ4Wm1WSFlYVnpjMmxoYmtKc2RYSWdhVzQ5SW1Kc1pXNWtUM1YwSWlCemRHUkVaWFpwWVhScGIyNDlJalF5SWlBdlBqd3ZabWxzZEdWeVBpQThZMnhwY0ZCaGRHZ2dhV1E5SW1OdmNtNWxjbk1pUGp4eVpXTjBJSGRwWkhSb1BTSXlPVEFpSUdobGFXZG9kRDBpTlRBd0lpQnllRDBpTkRJaUlISjVQU0kwTWlJZ0x6NDhMMk5zYVhCUVlYUm9Qanh3WVhSb0lHbGtQU0owWlhoMExYQmhkR2d0WVNJZ1pEMGlUVFF3SURFeUlFZ3lOVEFnUVRJNElESTRJREFnTUNBeElESTNPQ0EwTUNCV05EWXdJRUV5T0NBeU9DQXdJREFnTVNBeU5UQWdORGc0SUVnME1DQkJNamdnTWpnZ01DQXdJREVnTVRJZ05EWXdJRlkwTUNCQk1qZ2dNamdnTUNBd0lERWdOREFnTVRJZ2VpSWdMejQ4Y0dGMGFDQnBaRDBpYldsdWFXMWhjQ0lnWkQwaVRUSXpOQ0EwTkRSRE1qTTBJRFExTnk0NU5Ea2dNalF5TGpJeElEUTJNeUF5TlRNZ05EWXpJaUF2UGp4bWFXeDBaWElnYVdROUluUnZjQzF5WldkcGIyNHRZbXgxY2lJK1BHWmxSMkYxYzNOcFlXNUNiSFZ5SUdsdVBTSlRiM1Z5WTJWSGNtRndhR2xqSWlCemRHUkVaWFpwWVhScGIyNDlJakkwSWlBdlBqd3ZabWxzZEdWeVBqeHNhVzVsWVhKSGNtRmthV1Z1ZENCcFpEMGlaM0poWkMxMWNDSWdlREU5SWpFaUlIZ3lQU0l3SWlCNU1UMGlNU0lnZVRJOUlqQWlQanh6ZEc5d0lHOW1abk5sZEQwaU1DNHdJaUJ6ZEc5d0xXTnZiRzl5UFNKM2FHbDBaU0lnYzNSdmNDMXZjR0ZqYVhSNVBTSXhJaUF2UGp4emRHOXdJRzltWm5ObGREMGlMamtpSUhOMGIzQXRZMjlzYjNJOUluZG9hWFJsSWlCemRHOXdMVzl3WVdOcGRIazlJakFpSUM4K1BDOXNhVzVsWVhKSGNtRmthV1Z1ZEQ0OGJHbHVaV0Z5UjNKaFpHbGxiblFnYVdROUltZHlZV1F0Wkc5M2JpSWdlREU5SWpBaUlIZ3lQU0l4SWlCNU1UMGlNQ0lnZVRJOUlqRWlQanh6ZEc5d0lHOW1abk5sZEQwaU1DNHdJaUJ6ZEc5d0xXTnZiRzl5UFNKM2FHbDBaU0lnYzNSdmNDMXZjR0ZqYVhSNVBTSXhJaUF2UGp4emRHOXdJRzltWm5ObGREMGlNQzQ1SWlCemRHOXdMV052Ykc5eVBTSjNhR2wwWlNJZ2MzUnZjQzF2Y0dGamFYUjVQU0l3SWlBdlBqd3ZiR2x1WldGeVIzSmhaR2xsYm5RK1BHMWhjMnNnYVdROUltWmhaR1V0ZFhBaUlHMWhjMnREYjI1MFpXNTBWVzVwZEhNOUltOWlhbVZqZEVKdmRXNWthVzVuUW05NElqNDhjbVZqZENCM2FXUjBhRDBpTVNJZ2FHVnBaMmgwUFNJeElpQm1hV3hzUFNKMWNtd29JMmR5WVdRdGRYQXBJaUF2UGp3dmJXRnphejQ4YldGemF5QnBaRDBpWm1Ga1pTMWtiM2R1SWlCdFlYTnJRMjl1ZEdWdWRGVnVhWFJ6UFNKdlltcGxZM1JDYjNWdVpHbHVaMEp2ZUNJK1BISmxZM1FnZDJsa2RHZzlJakVpSUdobGFXZG9kRDBpTVNJZ1ptbHNiRDBpZFhKc0tDTm5jbUZrTFdSdmQyNHBJaUF2UGp3dmJXRnphejQ4YldGemF5QnBaRDBpYm05dVpTSWdiV0Z6YTBOdmJuUmxiblJWYm1sMGN6MGliMkpxWldOMFFtOTFibVJwYm1kQ2IzZ2lQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJR1pwYkd3OUluZG9hWFJsSWlBdlBqd3ZiV0Z6YXo0OGJHbHVaV0Z5UjNKaFpHbGxiblFnYVdROUltZHlZV1F0YzNsdFltOXNJajQ4YzNSdmNDQnZabVp6WlhROUlqQXVOeUlnYzNSdmNDMWpiMnh2Y2owaWQyaHBkR1VpSUhOMGIzQXRiM0JoWTJsMGVUMGlNU0lnTHo0OGMzUnZjQ0J2Wm1aelpYUTlJaTQ1TlNJZ2MzUnZjQzFqYjJ4dmNqMGlkMmhwZEdVaUlITjBiM0F0YjNCaFkybDBlVDBpTUNJZ0x6NDhMMnhwYm1WaGNrZHlZV1JwWlc1MFBqeHRZWE5ySUdsa1BTSm1ZV1JsTFhONWJXSnZiQ0lnYldGemEwTnZiblJsYm5SVmJtbDBjejBpZFhObGNsTndZV05sVDI1VmMyVWlQanh5WldOMElIZHBaSFJvUFNJeU9UQndlQ0lnYUdWcFoyaDBQU0l5TURCd2VDSWdabWxzYkQwaWRYSnNLQ05uY21Ga0xYTjViV0p2YkNraUlDOCtQQzl0WVhOclBqd3ZaR1ZtY3o0OFp5QmpiR2x3TFhCaGRHZzlJblZ5YkNnalkyOXlibVZ5Y3lraVBqeHlaV04wSUdacGJHdzlJbVkxWVRKbVpTSWdlRDBpTUhCNElpQjVQU0l3Y0hnaUlIZHBaSFJvUFNJeU9UQndlQ0lnYUdWcFoyaDBQU0kxTURCd2VDSWdMejQ4Y21WamRDQnpkSGxzWlQwaVptbHNkR1Z5T2lCMWNtd29JMll4S1NJZ2VEMGlNSEI0SWlCNVBTSXdjSGdpSUhkcFpIUm9QU0l5T1RCd2VDSWdhR1ZwWjJoMFBTSTFNREJ3ZUNJZ0x6NGdQR2NnYzNSNWJHVTlJbVpwYkhSbGNqcDFjbXdvSTNSdmNDMXlaV2RwYjI0dFlteDFjaWs3SUhSeVlXNXpabTl5YlRwelkyRnNaU2d4TGpVcE95QjBjbUZ1YzJadmNtMHRiM0pwWjJsdU9tTmxiblJsY2lCMGIzQTdJajQ4Y21WamRDQm1hV3hzUFNKdWIyNWxJaUI0UFNJd2NIZ2lJSGs5SWpCd2VDSWdkMmxrZEdnOUlqSTVNSEI0SWlCb1pXbG5hSFE5SWpVd01IQjRJaUF2UGp4bGJHeHBjSE5sSUdONFBTSTFNQ1VpSUdONVBTSXdjSGdpSUhKNFBTSXhPREJ3ZUNJZ2NuazlJakV5TUhCNElpQm1hV3hzUFNJak1EQXdJaUJ2Y0dGamFYUjVQU0l3TGpnMUlpQXZQand2Wno0OGNtVmpkQ0I0UFNJd0lpQjVQU0l3SWlCM2FXUjBhRDBpTWprd0lpQm9aV2xuYUhROUlqVXdNQ0lnY25nOUlqUXlJaUJ5ZVQwaU5ESWlJR1pwYkd3OUluSm5ZbUVvTUN3d0xEQXNNQ2tpSUhOMGNtOXJaVDBpY21kaVlTZ3lOVFVzTWpVMUxESTFOU3d3TGpJcElpQXZQand2Wno0OGRHVjRkQ0IwWlhoMExYSmxibVJsY21sdVp6MGliM0IwYVcxcGVtVlRjR1ZsWkNJK1BIUmxlSFJRWVhSb0lITjBZWEowVDJabWMyVjBQU0l0TVRBd0pTSWdabWxzYkQwaWQyaHBkR1VpSUdadmJuUXRabUZ0YVd4NVBTSW5RMjkxY21sbGNpQk9aWGNuTENCdGIyNXZjM0JoWTJVaUlHWnZiblF0YzJsNlpUMGlNVEJ3ZUNJZ2VHeHBibXM2YUhKbFpqMGlJM1JsZUhRdGNHRjBhQzFoSWo1VFVWSlVJT0tBb2lBd2VHWTFZVEptWlRRMVpqUm1NVE13T0RVd01tSXhZekV6Tm1JNVpXWTRZV1l4TXpZeE5ERXpPRElnUEdGdWFXMWhkR1VnWVdSa2FYUnBkbVU5SW5OMWJTSWdZWFIwY21saWRYUmxUbUZ0WlQwaWMzUmhjblJQWm1aelpYUWlJR1p5YjIwOUlqQWxJaUIwYnowaU1UQXdKU0lnWW1WbmFXNDlJakJ6SWlCa2RYSTlJak13Y3lJZ2NtVndaV0YwUTI5MWJuUTlJbWx1WkdWbWFXNXBkR1VpSUM4K1BDOTBaWGgwVUdGMGFENGdQSFJsZUhSUVlYUm9JSE4wWVhKMFQyWm1jMlYwUFNJd0pTSWdabWxzYkQwaWQyaHBkR1VpSUdadmJuUXRabUZ0YVd4NVBTSW5RMjkxY21sbGNpQk9aWGNuTENCdGIyNXZjM0JoWTJVaUlHWnZiblF0YzJsNlpUMGlNVEJ3ZUNJZ2VHeHBibXM2YUhKbFpqMGlJM1JsZUhRdGNHRjBhQzFoSWo1VFVWSlVJT0tBb2lBd2VHWTFZVEptWlRRMVpqUm1NVE13T0RVd01tSXhZekV6Tm1JNVpXWTRZV1l4TXpZeE5ERXpPRElnUEdGdWFXMWhkR1VnWVdSa2FYUnBkbVU5SW5OMWJTSWdZWFIwY21saWRYUmxUbUZ0WlQwaWMzUmhjblJQWm1aelpYUWlJR1p5YjIwOUlqQWxJaUIwYnowaU1UQXdKU0lnWW1WbmFXNDlJakJ6SWlCa2RYSTlJak13Y3lJZ2NtVndaV0YwUTI5MWJuUTlJbWx1WkdWbWFXNXBkR1VpSUM4K0lEd3ZkR1Y0ZEZCaGRHZytQSFJsZUhSUVlYUm9JSE4wWVhKMFQyWm1jMlYwUFNJMU1DVWlJR1pwYkd3OUluZG9hWFJsSWlCbWIyNTBMV1poYldsc2VUMGlKME52ZFhKcFpYSWdUbVYzSnl3Z2JXOXViM053WVdObElpQm1iMjUwTFhOcGVtVTlJakV3Y0hnaUlIaHNhVzVyT21oeVpXWTlJaU4wWlhoMExYQmhkR2d0WVNJK1QzQjBhVzFwZW05eUlPS0FvaUF3ZURBd01EQXdNREF3TURBd01EQXdNREF3TURBd01EQXdNREF3TURBd01EQXdNREF3TURBd01EQWdQR0Z1YVcxaGRHVWdZV1JrYVhScGRtVTlJbk4xYlNJZ1lYUjBjbWxpZFhSbFRtRnRaVDBpYzNSaGNuUlBabVp6WlhRaUlHWnliMjA5SWpBbElpQjBiejBpTVRBd0pTSWdZbVZuYVc0OUlqQnpJaUJrZFhJOUlqTXdjeUlnY21Wd1pXRjBRMjkxYm5ROUltbHVaR1ZtYVc1cGRHVWlJQzgrUEM5MFpYaDBVR0YwYUQ0OGRHVjRkRkJoZEdnZ2MzUmhjblJQWm1aelpYUTlJaTAxTUNVaUlHWnBiR3c5SW5kb2FYUmxJaUJtYjI1MExXWmhiV2xzZVQwaUowTnZkWEpwWlhJZ1RtVjNKeXdnYlc5dWIzTndZV05sSWlCbWIyNTBMWE5wZW1VOUlqRXdjSGdpSUhoc2FXNXJPbWh5WldZOUlpTjBaWGgwTFhCaGRHZ3RZU0krVDNCMGFXMXBlbTl5SU9LQW9pQXdlREF3TURBd01EQXdNREF3TURBd01EQXdNREF3TURBd01EQXdNREF3TURBd01EQXdNREF3TURBZ1BHRnVhVzFoZEdVZ1lXUmthWFJwZG1VOUluTjFiU0lnWVhSMGNtbGlkWFJsVG1GdFpUMGljM1JoY25SUFptWnpaWFFpSUdaeWIyMDlJakFsSWlCMGJ6MGlNVEF3SlNJZ1ltVm5hVzQ5SWpCeklpQmtkWEk5SWpNd2N5SWdjbVZ3WldGMFEyOTFiblE5SW1sdVpHVm1hVzVwZEdVaUlDOCtQQzkwWlhoMFVHRjBhRDQ4TDNSbGVIUStQR2NnYldGemF6MGlkWEpzS0NObVlXUmxMWE41YldKdmJDa2lQanh5WldOMElHWnBiR3c5SW01dmJtVWlJSGc5SWpCd2VDSWdlVDBpTUhCNElpQjNhV1IwYUQwaU1qa3djSGdpSUdobGFXZG9kRDBpTWpBd2NIZ2lJQzgrSUR4MFpYaDBJSGs5SWpjd2NIZ2lJSGc5SWpNeWNIZ2lJR1pwYkd3OUluZG9hWFJsSWlCbWIyNTBMV1poYldsc2VUMGlKME52ZFhKcFpYSWdUbVYzSnl3Z2JXOXViM053WVdObElpQm1iMjUwTFhkbGFXZG9kRDBpTWpBd0lpQm1iMjUwTFhOcGVtVTlJak0yY0hnaVBsTlJVbFE4TDNSbGVIUStQSFJsZUhRZ2VUMGlNVEUxY0hnaUlIZzlJak15Y0hnaUlHWnBiR3c5SW5kb2FYUmxJaUJtYjI1MExXWmhiV2xzZVQwaUowTnZkWEpwWlhJZ1RtVjNKeXdnYlc5dWIzTndZV05sSWlCbWIyNTBMWGRsYVdkb2REMGlNakF3SWlCbWIyNTBMWE5wZW1VOUlqSXdjSGdpUGxKaGJtc2dJekl2TVR3dmRHVjRkRDQ4TDJjK1BISmxZM1FnZUQwaU1UWWlJSGs5SWpFMklpQjNhV1IwYUQwaU1qVTRJaUJvWldsbmFIUTlJalEyT0NJZ2NuZzlJakkySWlCeWVUMGlNallpSUdacGJHdzlJbkpuWW1Fb01Dd3dMREFzTUNraUlITjBjbTlyWlQwaWNtZGlZU2d5TlRVc01qVTFMREkxTlN3d0xqSXBJaUF2UGp4bklHMWhjMnM5SW5WeWJDZ2pibTl1WlNraUlITjBlV3hsUFNKMGNtRnVjMlp2Y20wNmRISmhibk5zWVhSbEtETXdjSGdzTVRNd2NIZ3BJajQ4Y21WamRDQjNhV1IwYUQwaU1qTXdJaUJvWldsbmFIUTlJakl6TUNJZ2NuZzlJakU0Y0hnaUlISjVQU0l4T0hCNElpQm1hV3hzUFNKeVoySmhLREFzTUN3d0xEQXVNU2tpSUM4K1BDOW5QaUE4WnlCemRIbHNaVDBpZEhKaGJuTm1iM0p0T25SeVlXNXpiR0YwWlNneU9YQjRMQ0F6T0RSd2VDa2lQanh5WldOMElIZHBaSFJvUFNJeE16TndlQ0lnYUdWcFoyaDBQU0l5Tm5CNElpQnllRDBpT0hCNElpQnllVDBpT0hCNElpQm1hV3hzUFNKeVoySmhLREFzTUN3d0xEQXVOaWtpSUM4K1BIUmxlSFFnZUQwaU1USndlQ0lnZVQwaU1UZHdlQ0lnWm05dWRDMW1ZVzFwYkhrOUlpZERiM1Z5YVdWeUlFNWxkeWNzSUcxdmJtOXpjR0ZqWlNJZ1ptOXVkQzF6YVhwbFBTSXhNbkI0SWlCbWFXeHNQU0ozYUdsMFpTSStQSFJ6Y0dGdUlHWnBiR3c5SW5KblltRW9NalUxTERJMU5Td3lOVFVzTUM0MktTSStTVVE2SUR3dmRITndZVzQrTVRjeE56azROamt4T0RROEwzUmxlSFErUEM5blBpQThaeUJ6ZEhsc1pUMGlkSEpoYm5ObWIzSnRPblJ5WVc1emJHRjBaU2d5T1hCNExDQTBNVFJ3ZUNraVBqeHlaV04wSUhkcFpIUm9QU0l4TURWd2VDSWdhR1ZwWjJoMFBTSXlObkI0SWlCeWVEMGlPSEI0SWlCeWVUMGlPSEI0SWlCbWFXeHNQU0p5WjJKaEtEQXNNQ3d3TERBdU5pa2lJQzgrUEhSbGVIUWdlRDBpTVRKd2VDSWdlVDBpTVRkd2VDSWdabTl1ZEMxbVlXMXBiSGs5SWlkRGIzVnlhV1Z5SUU1bGR5Y3NJRzF2Ym05emNHRmpaU0lnWm05dWRDMXphWHBsUFNJeE1uQjRJaUJtYVd4c1BTSjNhR2wwWlNJK1BIUnpjR0Z1SUdacGJHdzlJbkpuWW1Fb01qVTFMREkxTlN3eU5UVXNNQzQyS1NJK1IyRnpJSFZ6WldRNklEd3ZkSE53WVc0K01Ed3ZkR1Y0ZEQ0OEwyYytJRHhuSUhOMGVXeGxQU0owY21GdWMyWnZjbTA2ZEhKaGJuTnNZWFJsS0RJNWNIZ3NJRFEwTkhCNEtTSStQSEpsWTNRZ2QybGtkR2c5SWpFeE1uQjRJaUJvWldsbmFIUTlJakkyY0hnaUlISjRQU0k0Y0hnaUlISjVQU0k0Y0hnaUlHWnBiR3c5SW5KblltRW9NQ3d3TERBc01DNDJLU0lnTHo0OGRHVjRkQ0I0UFNJeE1uQjRJaUI1UFNJeE4zQjRJaUJtYjI1MExXWmhiV2xzZVQwaUowTnZkWEpwWlhJZ1RtVjNKeXdnYlc5dWIzTndZV05sSWlCbWIyNTBMWE5wZW1VOUlqRXljSGdpSUdacGJHdzlJbmRvYVhSbElqNDhkSE53WVc0Z1ptbHNiRDBpY21kaVlTZ3lOVFVzTWpVMUxESTFOU3d3TGpZcElqNUhZWE1nYjNCMGFUb2dQQzkwYzNCaGJqNDVPU1U4TDNSbGVIUStQQzluUGp3dmMzWm5QZz09In0=");
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
