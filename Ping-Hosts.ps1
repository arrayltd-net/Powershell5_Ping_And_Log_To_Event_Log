Function Ping-Host($c){

    $Ping = Get-WmiObject -Class Win32_PingStatus -Filter "Address='$($c)' AND Timeout=1000"

    $StatusCodes = @{
        [uint32]0     = 'Success';
        [uint32]11001 = 'Buffer Too Small';
        [uint32]11002 = 'Destination Net Unreachable';
        [uint32]11003 = 'Destination Host Unreachable';
        [uint32]11004 = 'Destination Protocol Unreachable';
        [uint32]11005 = 'Destination Port Unreachable';
        [uint32]11006 = 'No Resources';
        [uint32]11007 = 'Bad Option';
        [uint32]11008 = 'Hardware Error';
        [uint32]11009 = 'Packet Too Big';
        [uint32]11010 = 'Request Timed Out';
        [uint32]11011 = 'Bad Request';
        [uint32]11012 = 'Bad Route';
        [uint32]11013 = 'TimeToLive Expired Transit';
        [uint32]11014 = 'TimeToLive Expired Reassembly';
        [uint32]11015 = 'Parameter Problem';
        [uint32]11016 = 'Source Quench';
        [uint32]11017 = 'Option Too Big';
        [uint32]11018 = 'Bad Destination';
        [uint32]11032 = 'Negotiating IPSEC';
        [uint32]11050 = 'General Failure'
        default = ""
    }
        
    return $StatusCodes[$Ping.StatusCode]
 }
 
Function Write-StatusToEventLog($status, $c){
    if($status -eq 0){
        $params = @{
            Logname = 'Application'
            Source = 'Technical Support Company'
            EntryType = 'Information'
            EventID = 1000
            Message = "The ping to $c was $status."
        }
     }
     
    if($status -ne 0){
        $params = @{
            Logname = 'Application'
            Source = 'Technical Support Company'
            EntryType = 'Error'
            EventID = 1001
            Message = "The ping to $c was $status."
        }
     }
     
    Write-EventLog @params
}

Function Ping-Hosts
 
  Param(
      [Parameter(
         HelpMessage = "Path to ASCII file containing hosts to ping.")]
         [string] $hosts
  )
    
  New-EventLog -LogName Application -Source "Technical Support Company"
  [array]$computers = Get-Content($hosts)
  foreach($c in $computers){               
     $status = Ping-Host $c
     Write-StatusToEventLog $status $c
    }
}
