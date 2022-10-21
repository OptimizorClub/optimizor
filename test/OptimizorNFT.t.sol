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

        assertEq(opt.tokenURI((SQRT_ID << 32) | 0), "data:application/json;base64,eyJuYW1lIjoiIE9wdGltaXpvcjogU1FSVCIsICJkZXNjcmlwdGlvbiI6IkFydDogU3BpcmFsIG9mIFRoZW9kb3J1cy5cbkxlYWRlcmJvYXJkOlxuMS4gMHhiNGM3OWRhYjhmMjU5YzdhZWU2ZTViMmFhNzI5ODIxODY0MjI3ZTg0IiwgImF0dHJpYnV0ZXMiOiBbeyAidHJhaXRfdHlwZSI6ICJMZWFkZXIiLCAidmFsdWUiOiAiTm8ifSwgeyAidHJhaXRfdHlwZSI6ICJUb3AgMyIsICJ2YWx1ZSI6ICJZZXMifSwgeyAidHJhaXRfdHlwZSI6ICJUb3AgMTAiLCAidmFsdWUiOiAiWWVzIn0gXSwiaW1hZ2UiOiAiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCM2FXUjBhRDBpTWprd0lpQm9aV2xuYUhROUlqVXdNQ0lnZG1sbGQwSnZlRDBpTUNBd0lESTVNQ0ExTURBaUlIaHRiRzV6UFNKb2RIUndPaTh2ZDNkM0xuY3pMbTl5Wnk4eU1EQXdMM04yWnlJZ2VHMXNibk02ZUd4cGJtczlKMmgwZEhBNkx5OTNkM2N1ZHpNdWIzSm5MekU1T1RrdmVHeHBibXNuUGp4a1pXWnpQanhtYVd4MFpYSWdhV1E5SW1ZeElqNDhabVZKYldGblpTQnlaWE4xYkhROUluQXdJaUI0YkdsdWF6cG9jbVZtUFNKa1lYUmhPbWx0WVdkbEwzTjJaeXQ0Yld3N1ltRnpaVFkwTEZCSVRqSmFlVUl6WVZkU01HRkVNRzVOYW10M1NubENiMXBYYkc1aFNGRTVTbnBWZDAxRFkyZGtiV3hzWkRCS2RtVkVNRzVOUTBGM1NVUkpOVTFEUVRGTlJFRnVTVWhvZEdKSE5YcFFVMlJ2WkVoU2QwOXBPSFprTTJRelRHNWpla3h0T1hsYWVUaDVUVVJCZDB3elRqSmFlV01yVUVoS2JGa3pVV2RrTW14clpFZG5PVXA2U1RWTlNFSTBTbmxDYjFwWGJHNWhTRkU1U25wVmQwMUlRalJLZVVKdFlWZDRjMUJUWTJwYWFsWm9UVzFhYkVwNU9DdFFRemw2Wkcxakt5SXZQaUE4Wm1WSmJXRm5aU0J5WlhOMWJIUTlJbkF4SWlCNGJHbHVhenBvY21WbVBTSmtZWFJoT21sdFlXZGxMM04yWnl0NGJXdzdZbUZ6WlRZMExGQklUakphZVVJellWZFNNR0ZFTUc1TmFtdDNTbmxDYjFwWGJHNWhTRkU1U25wVmQwMURZMmRrYld4c1pEQktkbVZFTUc1TlEwRjNTVVJKTlUxRFFURk5SRUZ1U1Vob2RHSkhOWHBRVTJSdlpFaFNkMDlwT0haa00yUXpURzVqZWt4dE9YbGFlVGg1VFVSQmQwd3pUakphZVdNclVFZE9jR050VG5OYVUwSnFaVVF3Yms5VVdXNUpSMDQxVUZOamVFMUVRVzVKU0VrNVNucEZlVTFJUWpSS2VVSnRZVmQ0YzFCVFkycE5SRUYzVFVSQmQwcDVPQ3RRUXpsNlpHMWpLeUl2UGlBOFptVkpiV0ZuWlNCeVpYTjFiSFE5SW5BeUlpQjRiR2x1YXpwb2NtVm1QU0prWVhSaE9tbHRZV2RsTDNOMlp5dDRiV3c3WW1GelpUWTBMRkJJVGpKYWVVSXpZVmRTTUdGRU1HNU5hbXQzU25sQ2IxcFhiRzVoU0ZFNVNucFZkMDFEWTJka2JXeHNaREJLZG1WRU1HNU5RMEYzU1VSSk5VMURRVEZOUkVGdVNVaG9kR0pITlhwUVUyUnZaRWhTZDA5cE9IWmtNMlF6VEc1amVreHRPWGxhZVRoNVRVUkJkMHd6VGpKYWVXTXJVRWRPY0dOdFRuTmFVMEpxWlVRd2JrMXFSVE5LZVVKcVpWUXdiazFVUVhkS2VVSjVVRk5qZUUxcVFuZGxRMk5uV20xc2MySkVNRzVKZWtVd1RWUk5ORTFwWTNaUWFuZDJZek5hYmxCblBUMGlJQzgrUEdabFNXMWhaMlVnY21WemRXeDBQU0p3TXlJZ2VHeHBibXM2YUhKbFpqMGlaR0YwWVRwcGJXRm5aUzl6ZG1jcmVHMXNPMkpoYzJVMk5DeFFTRTR5V25sQ00yRlhVakJoUkRCdVRXcHJkMHA1UW05YVYyeHVZVWhST1VwNlZYZE5RMk5uWkcxc2JHUXdTblpsUkRCdVRVTkJkMGxFU1RWTlEwRXhUVVJCYmtsSWFIUmlSelY2VUZOa2IyUklVbmRQYVRoMlpETmtNMHh1WTNwTWJUbDVXbms0ZVUxRVFYZE1NMDR5V25saksxQkhUbkJqYlU1eldsTkNhbVZFTUc1TmFrRTFTbmxDYW1WVU1HNU5WRUYzU25sQ2VWQlRZM2hOUkVKM1pVTmpaMXB0YkhOaVJEQnVTWHBCZDAxRVFYZE5RMk4yVUdwM2RtTXpXbTVRWnowOUlpQXZQanhtWlVKc1pXNWtJRzF2WkdVOUltOTJaWEpzWVhraUlHbHVQU0p3TUNJZ2FXNHlQU0p3TVNJZ0x6NDhabVZDYkdWdVpDQnRiMlJsUFNKbGVHTnNkWE5wYjI0aUlHbHVNajBpY0RJaUlDOCtQR1psUW14bGJtUWdiVzlrWlQwaWIzWmxjbXhoZVNJZ2FXNHlQU0p3TXlJZ2NtVnpkV3gwUFNKaWJHVnVaRTkxZENJZ0x6NDhabVZIWVhWemMybGhia0pzZFhJZ2FXNDlJbUpzWlc1a1QzVjBJaUJ6ZEdSRVpYWnBZWFJwYjI0OUlqUXlJaUF2UGp3dlptbHNkR1Z5UGlBOFkyeHBjRkJoZEdnZ2FXUTlJbU52Y201bGNuTWlQanh5WldOMElIZHBaSFJvUFNJeU9UQWlJR2hsYVdkb2REMGlOVEF3SWlCeWVEMGlORElpSUhKNVBTSTBNaUlnTHo0OEwyTnNhWEJRWVhSb1BqeHdZWFJvSUdsa1BTSjBaWGgwTFhCaGRHZ3RZU0lnWkQwaVRUUXdJREV5SUVneU5UQWdRVEk0SURJNElEQWdNQ0F4SURJM09DQTBNQ0JXTkRZd0lFRXlPQ0F5T0NBd0lEQWdNU0F5TlRBZ05EZzRJRWcwTUNCQk1qZ2dNamdnTUNBd0lERWdNVElnTkRZd0lGWTBNQ0JCTWpnZ01qZ2dNQ0F3SURFZ05EQWdNVElnZWlJZ0x6NDhjR0YwYUNCcFpEMGliV2x1YVcxaGNDSWdaRDBpVFRJek5DQTBORFJETWpNMElEUTFOeTQ1TkRrZ01qUXlMakl4SURRMk15QXlOVE1nTkRZeklpQXZQanhtYVd4MFpYSWdhV1E5SW5SdmNDMXlaV2RwYjI0dFlteDFjaUkrUEdabFIyRjFjM05wWVc1Q2JIVnlJR2x1UFNKVGIzVnlZMlZIY21Gd2FHbGpJaUJ6ZEdSRVpYWnBZWFJwYjI0OUlqSTBJaUF2UGp3dlptbHNkR1Z5UGp4c2FXNWxZWEpIY21Ga2FXVnVkQ0JwWkQwaVozSmhaQzExY0NJZ2VERTlJakVpSUhneVBTSXdJaUI1TVQwaU1TSWdlVEk5SWpBaVBqeHpkRzl3SUc5bVpuTmxkRDBpTUM0d0lpQnpkRzl3TFdOdmJHOXlQU0ozYUdsMFpTSWdjM1J2Y0MxdmNHRmphWFI1UFNJeElpQXZQanh6ZEc5d0lHOW1abk5sZEQwaUxqa2lJSE4wYjNBdFkyOXNiM0k5SW5kb2FYUmxJaUJ6ZEc5d0xXOXdZV05wZEhrOUlqQWlJQzgrUEM5c2FXNWxZWEpIY21Ga2FXVnVkRDQ4YkdsdVpXRnlSM0poWkdsbGJuUWdhV1E5SW1keVlXUXRaRzkzYmlJZ2VERTlJakFpSUhneVBTSXhJaUI1TVQwaU1DSWdlVEk5SWpFaVBqeHpkRzl3SUc5bVpuTmxkRDBpTUM0d0lpQnpkRzl3TFdOdmJHOXlQU0ozYUdsMFpTSWdjM1J2Y0MxdmNHRmphWFI1UFNJeElpQXZQanh6ZEc5d0lHOW1abk5sZEQwaU1DNDVJaUJ6ZEc5d0xXTnZiRzl5UFNKM2FHbDBaU0lnYzNSdmNDMXZjR0ZqYVhSNVBTSXdJaUF2UGp3dmJHbHVaV0Z5UjNKaFpHbGxiblErUEcxaGMyc2dhV1E5SW1aaFpHVXRkWEFpSUcxaGMydERiMjUwWlc1MFZXNXBkSE05SW05aWFtVmpkRUp2ZFc1a2FXNW5RbTk0SWo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCbWFXeHNQU0oxY213b0kyZHlZV1F0ZFhBcElpQXZQand2YldGemF6NDhiV0Z6YXlCcFpEMGlabUZrWlMxa2IzZHVJaUJ0WVhOclEyOXVkR1Z1ZEZWdWFYUnpQU0p2WW1wbFkzUkNiM1Z1WkdsdVowSnZlQ0krUEhKbFkzUWdkMmxrZEdnOUlqRWlJR2hsYVdkb2REMGlNU0lnWm1sc2JEMGlkWEpzS0NObmNtRmtMV1J2ZDI0cElpQXZQand2YldGemF6NDhiV0Z6YXlCcFpEMGlibTl1WlNJZ2JXRnphME52Ym5SbGJuUlZibWwwY3owaWIySnFaV04wUW05MWJtUnBibWRDYjNnaVBqeHlaV04wSUhkcFpIUm9QU0l4SWlCb1pXbG5hSFE5SWpFaUlHWnBiR3c5SW5kb2FYUmxJaUF2UGp3dmJXRnphejQ4YkdsdVpXRnlSM0poWkdsbGJuUWdhV1E5SW1keVlXUXRjM2x0WW05c0lqNDhjM1J2Y0NCdlptWnpaWFE5SWpBdU55SWdjM1J2Y0MxamIyeHZjajBpZDJocGRHVWlJSE4wYjNBdGIzQmhZMmwwZVQwaU1TSWdMejQ4YzNSdmNDQnZabVp6WlhROUlpNDVOU0lnYzNSdmNDMWpiMnh2Y2owaWQyaHBkR1VpSUhOMGIzQXRiM0JoWTJsMGVUMGlNQ0lnTHo0OEwyeHBibVZoY2tkeVlXUnBaVzUwUGp4dFlYTnJJR2xrUFNKbVlXUmxMWE41YldKdmJDSWdiV0Z6YTBOdmJuUmxiblJWYm1sMGN6MGlkWE5sY2xOd1lXTmxUMjVWYzJVaVBqeHlaV04wSUhkcFpIUm9QU0l5T1RCd2VDSWdhR1ZwWjJoMFBTSXlNREJ3ZUNJZ1ptbHNiRDBpZFhKc0tDTm5jbUZrTFhONWJXSnZiQ2tpSUM4K1BDOXRZWE5yUGp3dlpHVm1jejQ4WnlCamJHbHdMWEJoZEdnOUluVnliQ2dqWTI5eWJtVnljeWtpUGp4eVpXTjBJR1pwYkd3OUltWTFZVEptWlNJZ2VEMGlNSEI0SWlCNVBTSXdjSGdpSUhkcFpIUm9QU0l5T1RCd2VDSWdhR1ZwWjJoMFBTSTFNREJ3ZUNJZ0x6NDhjbVZqZENCemRIbHNaVDBpWm1sc2RHVnlPaUIxY213b0kyWXhLU0lnZUQwaU1IQjRJaUI1UFNJd2NIZ2lJSGRwWkhSb1BTSXlPVEJ3ZUNJZ2FHVnBaMmgwUFNJMU1EQndlQ0lnTHo0Z1BHY2djM1I1YkdVOUltWnBiSFJsY2pwMWNtd29JM1J2Y0MxeVpXZHBiMjR0WW14MWNpazdJSFJ5WVc1elptOXliVHB6WTJGc1pTZ3hMalVwT3lCMGNtRnVjMlp2Y20wdGIzSnBaMmx1T21ObGJuUmxjaUIwYjNBN0lqNDhjbVZqZENCbWFXeHNQU0p1YjI1bElpQjRQU0l3Y0hnaUlIazlJakJ3ZUNJZ2QybGtkR2c5SWpJNU1IQjRJaUJvWldsbmFIUTlJalV3TUhCNElpQXZQanhsYkd4cGNITmxJR040UFNJMU1DVWlJR041UFNJd2NIZ2lJSEo0UFNJeE9EQndlQ0lnY25rOUlqRXlNSEI0SWlCbWFXeHNQU0lqTURBd0lpQnZjR0ZqYVhSNVBTSXdMamcxSWlBdlBqd3ZaejQ4Y21WamRDQjRQU0l3SWlCNVBTSXdJaUIzYVdSMGFEMGlNamt3SWlCb1pXbG5hSFE5SWpVd01DSWdjbmc5SWpReUlpQnllVDBpTkRJaUlHWnBiR3c5SW5KblltRW9NQ3d3TERBc01Da2lJSE4wY205clpUMGljbWRpWVNneU5UVXNNalUxTERJMU5Td3dMaklwSWlBdlBqd3ZaejQ4ZEdWNGRDQjBaWGgwTFhKbGJtUmxjbWx1WnowaWIzQjBhVzFwZW1WVGNHVmxaQ0krUEhSbGVIUlFZWFJvSUhOMFlYSjBUMlptYzJWMFBTSXRNVEF3SlNJZ1ptbHNiRDBpZDJocGRHVWlJR1p2Ym5RdFptRnRhV3g1UFNJblEyOTFjbWxsY2lCT1pYY25MQ0J0YjI1dmMzQmhZMlVpSUdadmJuUXRjMmw2WlQwaU1UQndlQ0lnZUd4cGJtczZhSEpsWmowaUkzUmxlSFF0Y0dGMGFDMWhJajVUVVZKVUlPS0FvaUF3ZUdZMVlUSm1aVFExWmpSbU1UTXdPRFV3TW1JeFl6RXpObUk1WldZNFlXWXhNell4TkRFek9ESWdQR0Z1YVcxaGRHVWdZV1JrYVhScGRtVTlJbk4xYlNJZ1lYUjBjbWxpZFhSbFRtRnRaVDBpYzNSaGNuUlBabVp6WlhRaUlHWnliMjA5SWpBbElpQjBiejBpTVRBd0pTSWdZbVZuYVc0OUlqQnpJaUJrZFhJOUlqTXdjeUlnY21Wd1pXRjBRMjkxYm5ROUltbHVaR1ZtYVc1cGRHVWlJQzgrUEM5MFpYaDBVR0YwYUQ0Z1BIUmxlSFJRWVhSb0lITjBZWEowVDJabWMyVjBQU0l3SlNJZ1ptbHNiRDBpZDJocGRHVWlJR1p2Ym5RdFptRnRhV3g1UFNJblEyOTFjbWxsY2lCT1pYY25MQ0J0YjI1dmMzQmhZMlVpSUdadmJuUXRjMmw2WlQwaU1UQndlQ0lnZUd4cGJtczZhSEpsWmowaUkzUmxlSFF0Y0dGMGFDMWhJajVUVVZKVUlPS0FvaUF3ZUdZMVlUSm1aVFExWmpSbU1UTXdPRFV3TW1JeFl6RXpObUk1WldZNFlXWXhNell4TkRFek9ESWdQR0Z1YVcxaGRHVWdZV1JrYVhScGRtVTlJbk4xYlNJZ1lYUjBjbWxpZFhSbFRtRnRaVDBpYzNSaGNuUlBabVp6WlhRaUlHWnliMjA5SWpBbElpQjBiejBpTVRBd0pTSWdZbVZuYVc0OUlqQnpJaUJrZFhJOUlqTXdjeUlnY21Wd1pXRjBRMjkxYm5ROUltbHVaR1ZtYVc1cGRHVWlJQzgrSUR3dmRHVjRkRkJoZEdnK1BIUmxlSFJRWVhSb0lITjBZWEowVDJabWMyVjBQU0kxTUNVaUlHWnBiR3c5SW5kb2FYUmxJaUJtYjI1MExXWmhiV2xzZVQwaUowTnZkWEpwWlhJZ1RtVjNKeXdnYlc5dWIzTndZV05sSWlCbWIyNTBMWE5wZW1VOUlqRXdjSGdpSUhoc2FXNXJPbWh5WldZOUlpTjBaWGgwTFhCaGRHZ3RZU0krVDNCMGFXMXBlbTl5SU9LQW9pQXdlREF3TURBd01EQXdNREF3TURBd01EQXdNREF3TURBd01EQXdNREF3TURBd01EQXdNREF3TURBZ1BHRnVhVzFoZEdVZ1lXUmthWFJwZG1VOUluTjFiU0lnWVhSMGNtbGlkWFJsVG1GdFpUMGljM1JoY25SUFptWnpaWFFpSUdaeWIyMDlJakFsSWlCMGJ6MGlNVEF3SlNJZ1ltVm5hVzQ5SWpCeklpQmtkWEk5SWpNd2N5SWdjbVZ3WldGMFEyOTFiblE5SW1sdVpHVm1hVzVwZEdVaUlDOCtQQzkwWlhoMFVHRjBhRDQ4ZEdWNGRGQmhkR2dnYzNSaGNuUlBabVp6WlhROUlpMDFNQ1VpSUdacGJHdzlJbmRvYVhSbElpQm1iMjUwTFdaaGJXbHNlVDBpSjBOdmRYSnBaWElnVG1WM0p5d2diVzl1YjNOd1lXTmxJaUJtYjI1MExYTnBlbVU5SWpFd2NIZ2lJSGhzYVc1ck9taHlaV1k5SWlOMFpYaDBMWEJoZEdndFlTSStUM0IwYVcxcGVtOXlJT0tBb2lBd2VEQXdNREF3TURBd01EQXdNREF3TURBd01EQXdNREF3TURBd01EQXdNREF3TURBd01EQXdNREFnUEdGdWFXMWhkR1VnWVdSa2FYUnBkbVU5SW5OMWJTSWdZWFIwY21saWRYUmxUbUZ0WlQwaWMzUmhjblJQWm1aelpYUWlJR1p5YjIwOUlqQWxJaUIwYnowaU1UQXdKU0lnWW1WbmFXNDlJakJ6SWlCa2RYSTlJak13Y3lJZ2NtVndaV0YwUTI5MWJuUTlJbWx1WkdWbWFXNXBkR1VpSUM4K1BDOTBaWGgwVUdGMGFENDhMM1JsZUhRK1BHY2diV0Z6YXowaWRYSnNLQ05tWVdSbExYTjViV0p2YkNraVBqeHlaV04wSUdacGJHdzlJbTV2Ym1VaUlIZzlJakJ3ZUNJZ2VUMGlNSEI0SWlCM2FXUjBhRDBpTWprd2NIZ2lJR2hsYVdkb2REMGlNakF3Y0hnaUlDOCtJRHgwWlhoMElIazlJamN3Y0hnaUlIZzlJak15Y0hnaUlHWnBiR3c5SW5kb2FYUmxJaUJtYjI1MExXWmhiV2xzZVQwaUowTnZkWEpwWlhJZ1RtVjNKeXdnYlc5dWIzTndZV05sSWlCbWIyNTBMWGRsYVdkb2REMGlNakF3SWlCbWIyNTBMWE5wZW1VOUlqTTJjSGdpUGxOUlVsUThMM1JsZUhRK1BIUmxlSFFnZVQwaU1URTFjSGdpSUhnOUlqTXljSGdpSUdacGJHdzlJbmRvYVhSbElpQm1iMjUwTFdaaGJXbHNlVDBpSjBOdmRYSnBaWElnVG1WM0p5d2diVzl1YjNOd1lXTmxJaUJtYjI1MExYZGxhV2RvZEQwaU1qQXdJaUJtYjI1MExYTnBlbVU5SWpJd2NIZ2lQbEpoYm1zZ0l6SXZNVHd2ZEdWNGRENDhMMmMrUEhKbFkzUWdlRDBpTVRZaUlIazlJakUySWlCM2FXUjBhRDBpTWpVNElpQm9aV2xuYUhROUlqUTJPQ0lnY25nOUlqSTJJaUJ5ZVQwaU1qWWlJR1pwYkd3OUluSm5ZbUVvTUN3d0xEQXNNQ2tpSUhOMGNtOXJaVDBpY21kaVlTZ3lOVFVzTWpVMUxESTFOU3d3TGpJcElpQXZQanhuSUcxaGMyczlJblZ5YkNnamJtOXVaU2tpSUhOMGVXeGxQU0owY21GdWMyWnZjbTA2ZEhKaGJuTnNZWFJsS0RNd2NIZ3NNVE13Y0hncElqNDhjbVZqZENCM2FXUjBhRDBpTWpNd0lpQm9aV2xuYUhROUlqSXpNQ0lnY25nOUlqRTRjSGdpSUhKNVBTSXhPSEI0SWlCbWFXeHNQU0p5WjJKaEtEQXNNQ3d3TERBdU1Ta2lJQzgrUEM5blBpQThaeUJ6ZEhsc1pUMGlkSEpoYm5ObWIzSnRPblJ5WVc1emJHRjBaU2d5T1hCNExDQXpPRFJ3ZUNraVBqeHlaV04wSUhkcFpIUm9QU0l4TXpOd2VDSWdhR1ZwWjJoMFBTSXlObkI0SWlCeWVEMGlPSEI0SWlCeWVUMGlPSEI0SWlCbWFXeHNQU0p5WjJKaEtEQXNNQ3d3TERBdU5pa2lJQzgrUEhSbGVIUWdlRDBpTVRKd2VDSWdlVDBpTVRkd2VDSWdabTl1ZEMxbVlXMXBiSGs5SWlkRGIzVnlhV1Z5SUU1bGR5Y3NJRzF2Ym05emNHRmpaU0lnWm05dWRDMXphWHBsUFNJeE1uQjRJaUJtYVd4c1BTSjNhR2wwWlNJK1BIUnpjR0Z1SUdacGJHdzlJbkpuWW1Fb01qVTFMREkxTlN3eU5UVXNNQzQyS1NJK1NVUTZJRHd2ZEhOd1lXNCtNVGN4TnprNE5qa3hPRFE4TDNSbGVIUStQQzluUGlBOFp5QnpkSGxzWlQwaWRISmhibk5tYjNKdE9uUnlZVzV6YkdGMFpTZ3lPWEI0TENBME1UUndlQ2tpUGp4eVpXTjBJSGRwWkhSb1BTSXhNRFZ3ZUNJZ2FHVnBaMmgwUFNJeU5uQjRJaUJ5ZUQwaU9IQjRJaUJ5ZVQwaU9IQjRJaUJtYVd4c1BTSnlaMkpoS0RBc01Dd3dMREF1TmlraUlDOCtQSFJsZUhRZ2VEMGlNVEp3ZUNJZ2VUMGlNVGR3ZUNJZ1ptOXVkQzFtWVcxcGJIazlJaWREYjNWeWFXVnlJRTVsZHljc0lHMXZibTl6Y0dGalpTSWdabTl1ZEMxemFYcGxQU0l4TW5CNElpQm1hV3hzUFNKM2FHbDBaU0krUEhSemNHRnVJR1pwYkd3OUluSm5ZbUVvTWpVMUxESTFOU3d5TlRVc01DNDJLU0krUjJGeklIVnpaV1E2SUR3dmRITndZVzQrTUR3dmRHVjRkRDQ4TDJjK0lEeG5JSE4wZVd4bFBTSjBjbUZ1YzJadmNtMDZkSEpoYm5Oc1lYUmxLREk1Y0hnc0lEUTBOSEI0S1NJK1BISmxZM1FnZDJsa2RHZzlJakV4TW5CNElpQm9aV2xuYUhROUlqSTJjSGdpSUhKNFBTSTRjSGdpSUhKNVBTSTRjSGdpSUdacGJHdzlJbkpuWW1Fb01Dd3dMREFzTUM0MktTSWdMejQ4ZEdWNGRDQjRQU0l4TW5CNElpQjVQU0l4TjNCNElpQm1iMjUwTFdaaGJXbHNlVDBpSjBOdmRYSnBaWElnVG1WM0p5d2diVzl1YjNOd1lXTmxJaUJtYjI1MExYTnBlbVU5SWpFeWNIZ2lJR1pwYkd3OUluZG9hWFJsSWo0OGRITndZVzRnWm1sc2JEMGljbWRpWVNneU5UVXNNalUxTERJMU5Td3dMallwSWo1SFlYTWdiM0IwYVRvZ1BDOTBjM0JoYmo0NU9TVThMM1JsZUhRK1BDOW5Qand2YzNablBnPT0ifQ==");
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
