@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row">
        <div class="col-md-8 col-md-offset-2">
            <div class="panel panel-default">
                <div class="panel-heading">Dashboard</div>

                <div class="panel-body">
                    @if (session('status'))
                        <div class="alert alert-success">
                            {{ session('status') }}
                        </div>
                    @endif
     			<div class="row">
       				<div class="col-md-6">
				    <div class="panel panel-default">
					<table class="table table-striped">
					 <thead>
      					       	<center><b>Current Membership</b><br>
					       	<img src="/img/rating/1_stars_T.png" style="width: 100px"><br>
						</center> 
					 </thead>
					 
					 <tbody>
    					  <tr>
      					    <td>Loan Limit</td>
      					    <td class='text-right'>300 USD (~ 0.26 ETH)</td>
    					  </tr>
    					  <tr>
      					    <td>Intrest Rate</td>
      					    <td class='text-right'>23%</td>
    					  </tr>
					  <tr>
      					    <td>Expires</td>
      					    <td class='text-right'>01/05/2019</td>
    					  </tr>
					  <tr>
					    <td colspan="2"><center><a href="/upgrade" class="btn btn-success" role="button">Upgrade</a></center></td>
					  </tr>
					 </tbody>
					</table>
				    </div>
				    
       				</div>
       				<div class="col-md-6">
				  
				    <center>
         				<b>Loan Payment Address</b><br>
					<a href="https://etherscan.io/address/0x3da15075D449eE0d70efBE889ef23401Cb36c471" target="_blank">0x3da15075D449eE0d70efBE889ef23401Cb36c471</a><br><br>
					<button type="button" class="btn btn-success">Deposit Collateral</button><br><br>

					<b>Collateral Value</b><br>
					0.55744 ETH<br>
					<button type="button" class="btn btn-warning" disabled>Withdraw</button>
				    </center>
       				</div>
     			</div>
			<br>
			<div class="row">
				<div class="col-md-6">
				    <div class="panel panel-default">
					<table class="table table-striped">
  					 <thead>
      					    <center><b>Current Statement</b></center>
  					</thead>
  					<tbody>
    					  <tr>
      					    <td>Active Loan</td>
					    <td></td>
					    <td></td>
      					    <td class='text-right'>0.05265642 ETH</td>
    					  </tr>
    					  <tr>
      					    <td>Min. Payment Due</td>
					    <td></td>
					    <td></td>
      					    <td class='text-right'>0.01 ETH</td>
    					  </tr>
   					  <tr>
      					    <td>Payment Due Date</td>
					    <td></td>
					    <td></td>
      					    <td class='text-right'>02/08/2018</td>
    					  </tr>
					  <tr>
      					    <td>Intrest Rate</td>
					    <td></td>
					    <td></td>
      					    <td class='text-right'>23%</td>
    					  </tr>
  					 </tbody>
				      	</table>
				    </div>
				</div>
				<div class="col-md-6">
				  <div class="panel panel-default">
				    <table class="table table-striped">
  					 <thead>
      					    <center><b>Previous Statement</b></center>
  					</thead>
  					<tbody>
    					  <tr>
      					    <td>Loan</td>
					    <td></td>
					    <td></td>
      					    <td class='text-right'>0 ETH</td>
    					  </tr>
    					  <tr>
      					    <td>Last Payment</td>
					    <td></td>
					    <td></td>
      					    <td class='text-right'>0 ETH</td>
    					  </tr>
   					  <tr>
      					    <td>Last Payment Date</td>
					    <td></td>
					    <td></td>
      					    <td class='text-right'></td>
    					  </tr>
					  <tr>
      					    <td>Intrest Paid</td>
					    <td></td>
					    <td></td>
      					    <td class='text-right'>0 ETH</td>
    					  </tr>
  					 </tbody>
				      </table>
				  </div>
				</div>
			</div>
			<br>
			<div class="row">
				<center>
					<div class="col-md-2">
					</div>
					<div class="col-md-8">
					<div class="panel panel-default">
					<table class="table table-striped">
					 <thead>
						<h3><b>Request Loan</b></h3>
					 </thead>
					 <tbody>
    					  <tr>
      					    <td>Available Credit</td>
      					    <td class='text-right'>0.20734358 ETH</td>
    					  </tr>
    					  <tr>
      					    <td>Payment Due Date</td>
      					    <td class='text-right'>02/08/2018</td>
    					  </tr>
					  <td>Intrest Rate</td>
      					    <td class='text-right'>23%</td>
					  <tr>
      					    <td>Loan Amount</td>
      					    <td class='text-right'>Max. <input type="text" class="form-control form-rounded"/></td>
    					  </tr>
					  <tr>
      					    <td>To Address</td>
      					    <td class='text-right'><input type="text" class="form-control form-rounded"/></td>
    					  </tr>
					  <tr>
					    <td colspan="2"><center><a href="" class="btn btn-danger" role="button">Submit Request</a></center></td>
					  </tr>
					 </tbody>
					</table>
					</div>
					<br>
					</div>
					<div class="col-md-2">
					</div>
				</center>	
			</div>
                </div>
            </div>

	    <div class="panel panel-default">
                <div class="panel-heading">Transaction History</div>
    		<div class="table-responsive">
        		<table class="table table-bordered">
            			<thead>
                			<tr>
                    				<th>Txid</th>
                    				<th>Amount</th>
                    				<th>TxHash</th>
                    				<th>Type</th>
						<th>Date</th>
						<th>Status</th>
                			</tr>
            			</thead>
            			<tbody>
					<tr>
                    				<td>42733</td>
                    				<td>0.05265642 ETH</td>
                    				<td><a href="https://etherscan.io/tx/0x31f901eb28616fd083be65a1a9f6db1c0278ce52651f8bfe674776c97d0f812a" target="_blank">0x31f901eb2...</a></td>
                    				<td>Payment</td>
						<td>01/20/2018 @11:13am</td>
						<td>Pending (4/30)</td>
                			</tr>
					<tr>
                    				<td>38351</td>
                    				<td>0.05165642 ETH</td>
                    				<td><a href="https://etherscan.io/tx/0x31f901eb28616fd083be65a1a9f6db1c0278ce52651f8bfe674776c97d0f812a" target="_blank">0x31f901eb20...</a></td>
                    				<td>Loan</td>
						<td>01/08/2018 @4:40pm</td>
						<td>Confirmed</td>
                			</tr>
					<tr>
                    				<td>38274</td>
                    				<td>42.886259750000001024 EOS</td>
                    				<td><a href="https://etherscan.io/tx/0xd48e6ce66716b875680a048814b040c1b588efbee3c97836b288dabf8cad32f4" target="_blank">0xd48e6ce667...</a></td>
                    				<td>Deposit</td>
						<td>01/08/2018 @4:29pm</td>
						<td>Confirmed</td>
                			</tr>
            			</tbody>
        		</table>
    		</div>
            </div>

        </div>
    </div>
</div>
@endsection
