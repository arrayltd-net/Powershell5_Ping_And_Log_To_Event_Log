Function Process-Ping($host_to_test){

    $Ping = Get-WmiObject -Class Win32_PingStatus -Filter "Address='$($host_to_test)' AND Timeout=1000"
    return $Ping.StatusCode
}

Function Convert-StatusCode ($status){

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
    
    }
    
    try{
        return $StatusCodes[$status]
    }
    catch{
        return "Unspecified error. No status code returned. Problem could be DNS-related if pinging by hostname."
    }
}

Function Output-Message($host_to_test, $verbose){
    return  "The ping to $host_to_test reported: $verbose."
}
 
Function Write-StatusToEventLog($status, $verbose, $host_to_test, $EventIDOnError, $EventIDOnSuccess, $source){
    if($status -eq 0){
   
        $params = @{
            Logname = 'Application'
            Source = $source
            EntryType = 'Information'
            EventID = $EventIDOnSuccess
            Message = Output-Message $host_to_test $verbose
        }
    }
     
    if($status -ne 0){
   
        $params = @{
            Logname = 'Application'
            Source = $source
            EntryType = 'Error'
            EventID = $EventIDOnError
            Message = Output-Message $host_to_test $verbose
        }
    }
     
    Write-EventLog @params
}

Function Ping-Hosts{
 
  Param(
      [Parameter(Mandatory=$true,
         HelpMessage = "Path to ASCII file containing hosts to ping.")]
         [string] $hosts,
      [Parameter(Mandatory=$true,
         HelpMessage = "Event ID to record if there's an error pinging the host.")]
         [string] $EventIDOnError,
      [Parameter(Mandatory=$true,
         HelpMessage = "Event ID to record if pinging the host is successful.")]
         [string] $EventIDOnSuccess,
      [Parameter(Mandatory=$true,
         HelpMessage = "Application Source to display in Windows Logs > Application Log entry. E.G. Ping Test PS Script.")]
         [string] $source
  )
  
  #this try only succeeds once: the first time it is run on this computer.
  try{  
    New-EventLog -LogName Application -Source "$source" -ErrorAction SilentlyContinue
  }
  catch{}

  [array]$hosts = Get-Content($hosts)
  foreach($host_to_test in $hosts){               
     $status = Process-Ping $host_to_test
     $verbose = Convert-StatusCode $status
     Write-StatusToEventLog $status $verbose $host_to_test $EventIDOnError $EventIDOnSuccess $source
    
  }
}

 

