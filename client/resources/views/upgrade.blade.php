@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row">
        <div class="col-md-8 col-md-offset-2">
            <div class="panel panel-default">
                <div class="panel-heading">Membership Levels</div>

                <div class="panel-body">
                    @if (session('status'))
                        <div class="alert alert-success">
                            {{ session('status') }}
                        </div>
                    @endif
			<div class="row">
				<center>
					<b>Membership Payment Address</b><br>
					<a href="https://etherscan.io/address/0x3da15075D449eE0d70efBE889ef23401Cb36c471" target="_blank">0x3da15075D449eE0d70efBE889ef23401Cb36c471</a><br><br>
					<div class="col-md-3">
					</div>
					<div class="col-md-6">
					<div class="panel panel-default">
					<table class="table table-striped">
					 <thead>
					  <b>Current Membership</b><br>
					  <img src="/img/rating/1_stars_T.png" style="width: 100px"><br><br>
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
					 </tbody>
					</table>
					</div>
					<br>
					</div>
					<div class="col-md-3">
					</div>
				</center>	
			</div>
			<div class="row">
				<center><h3><b>Membership Levels</b></h3><br><br>
				</center>
			</div>
     			<div class="row">
				<div class="col-md-6">
				    <div class="panel panel-default">
					<table class="table table-striped">
  					 <thead>
      					    <center><img src="/img/rating/0_stars_T.png" style="width: 100px"><br><br></center>
  					</thead>
  					<tbody>
    					  <tr>
      					    <td>Loan Limit</td>
      					    <td class='text-right'>50 USD (~ 0.04 ETH)</td>
    					  </tr>
    					  <tr>
      					    <td>Intrest Rate</td>
      					    <td class='text-right'>25%</td>
    					  </tr>
					  <tr>
      					    <td>1 Year Membership</td>
      					    <td class='text-right'>1 TKL</td>
    					  </tr>
  					 </tbody>
				      	</table>
				    </div>
				</div>
				<div class="col-md-6">
				  <div class="panel panel-default">
				    <table class="table table-striped">
  					 <thead>
      					    <center><img src="/img/rating/0_and_half_star_T.png" style="width: 100px"><br><br></center>
  					</thead>
  					<tbody>
    					  <tr>
      					    <td>Loan Limit</td>
      					    <td class='text-right'>125 USD (~ 0.11 ETH)</td>
    					  </tr>
    					  <tr>
      					    <td>Intrest Rate</td>
      					    <td class='text-right'>24%</td>
    					  </tr>
					  <tr>
      					    <td>1 Year Membership</td>
      					    <td class='text-right'>2 TKL</td>
    					  </tr>
  					 </tbody>
				      </table>
				  </div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-6">
				    <div class="panel panel-default">
					<table class="table table-striped">
  					 <thead>
      					    <center><img src="/img/rating/1_stars_T.png" style="width: 100px"><br><br></center>
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
      					    <td>1 Year Membership</td>
      					    <td class='text-right'>3 TKL</td>
    					  </tr>
  					 </tbody>
				      	</table>
				    </div>
				</div>
				<div class="col-md-6">
				  <div class="panel panel-default">
				    <table class="table table-striped">
  					 <thead>
      					    <center><img src="/img/rating/1_and_a_half_stars_T.png" style="width: 100px"><br><br></center>
  					</thead>
  					<tbody>
    					  <tr>
      					    <td>Loan Limit</td>
      					    <td class='text-right'>700 USD (~ 0.60 ETH)</td>
    					  </tr>
    					  <tr>
      					    <td>Intrest Rate</td>
      					    <td class='text-right'>22%</td>
    					  </tr>
					  <tr>
      					    <td>1 Year Membership</td>
      					    <td class='text-right'>5 TKL</td>
    					  </tr>
  					 </tbody>
				      </table>
				  </div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-6">
				    <div class="panel panel-default">
					<table class="table table-striped">
  					 <thead>
      					    <center><img src="/img/rating/2_stars_T.png" style="width: 100px"><br><br></center>
  					</thead>
  					<tbody>
    					  <tr>
      					    <td>Loan Limit</td>
      					    <td class='text-right'>1,500 USD (~ 1.28 ETH)</td>
    					  </tr>
    					  <tr>
      					    <td>Intrest Rate</td>
      					    <td class='text-right'>21%</td>
    					  </tr>
					  <tr>
      					    <td>1 Year Membership</td>
      					    <td class='text-right'>9 TKL</td>
    					  </tr>
  					 </tbody>
				      	</table>
				    </div>
				</div>
				<div class="col-md-6">
				  <div class="panel panel-default">
				    <table class="table table-striped">
  					 <thead>
      					    <center><img src="/img/rating/2_and_a_half_stars_T.png" style="width: 100px"><br><br></center>
  					</thead>
  					<tbody>
    					  <tr>
      					    <td>Loan Limit</td>
      					    <td class='text-right'>3,200 USD (~ 2.72 ETH)</td>
    					  </tr>
    					  <tr>
      					    <td>Intrest Rate</td>
      					    <td class='text-right'>20%</td>
    					  </tr>
					  <tr>
      					    <td>1 Year Membership</td>
      					    <td class='text-right'>17 TKL</td>
    					  </tr>
  					 </tbody>
				      </table>
				  </div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-6">
				    <div class="panel panel-default">
					<table class="table table-striped">
  					 <thead>
      					    <center><img src="/img/rating/3_stars_T.png" style="width: 100px"><br><br></center>
  					</thead>
  					<tbody>
    					  <tr>
      					    <td>Loan Limit</td>
      					    <td class='text-right'>9,500 USD (~ 8.08 ETH)</td>
    					  </tr>
    					  <tr>
      					    <td>Intrest Rate</td>
      					    <td class='text-right'>19%</td>
    					  </tr>
					  <tr>
      					    <td>1 Year Membership</td>
      					    <td class='text-right'>33 TKL</td>
    					  </tr>
  					 </tbody>
				      	</table>
				    </div>
				</div>
				<div class="col-md-6">
				  <div class="panel panel-default">
				    <table class="table table-striped">
  					 <thead>
      					    <center><img src="/img/rating/3_and_a_half_stars_T.png" style="width: 100px"><br><br></center>
  					</thead>
  					<tbody>
    					  <tr>
      					    <td>Loan Limit</td>
      					    <td class='text-right'>20,000 USD (~ 17.02 ETH)</td>
    					  </tr>
    					  <tr>
      					    <td>Intrest Rate</td>
      					    <td class='text-right'>18%</td>
    					  </tr>
					  <tr>
      					    <td>1 Year Membership</td>
      					    <td class='text-right'>65 TKL</td>
    					  </tr>
  					 </tbody>
				      </table>
				  </div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-6">
				    <div class="panel panel-default">
					<table class="table table-striped">
  					 <thead>
      					    <center><img src="/img/rating/4_stars_T.png" style="width: 100px"><br><br></center>
  					</thead>
  					<tbody>
    					  <tr>
      					    <td>Loan Limit</td>
      					    <td class='text-right'>45,000 USD (~ 38.30 ETH)</td>
    					  </tr>
    					  <tr>
      					    <td>Intrest Rate</td>
      					    <td class='text-right'>17%</td>
    					  </tr>
					  <tr>
      					    <td>1 Year Membership</td>
      					    <td class='text-right'>129 TKL</td>
    					  </tr>
  					 </tbody>
				      	</table>
				    </div>
				</div>
				<div class="col-md-6">
				   <div class="panel panel-default">
				    <table class="table table-striped">
  					 <thead>
      					    <center><img src="/img/rating/4_and_a_half_stars_T.png" style="width: 100px"><br><br></center>
  					</thead>
  					<tbody>
    					  <tr>
      					    <td>Loan Limit</td>
      					    <td class='text-right'>100,000 USD (~ 85.10 ETH)</td>
    					  </tr>
    					  <tr>
      					    <td>Intrest Rate</td>
      					    <td class='text-right'>16%</td>
    					  </tr>
					  <tr>
      					    <td>1 Year Membership</td>
      					    <td class='text-right'>257 TKL</td>
    					  </tr>
  					 </tbody>
				      </table>
				  </div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-3">
				</div>

				<div class="col-md-6">
				  <div class="panel panel-default">
				    <table class="table table-striped">
  					 <thead>
      					    <center><img src="/img/rating/5_stars_T.png" style="width: 100px"><br><br></center>
  					</thead>
  					<tbody>
    					  <tr>
      					    <td>Loan Limit</td>
      					    <td class='text-right'>250,000 USD (~ 212.75 ETH)</td>
    					  </tr>
    					  <tr>
      					    <td>Intrest Rate</td>
      					    <td class='text-right'>15%</td>
    					  </tr>
					  <tr>
      					    <td>1 Year Membership</td>
      					    <td class='text-right'>513 TKL</td>
    					  </tr>
  					 </tbody>
				      </table>
				  </div>
				</div>
				<div class="col-md-3">
				</div>
			</div>
                </div>
	    </div>

	    <div class="panel panel-default">
                <div class="panel-heading">Membership History</div>
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
                    				<td>3 TKL</td>
                    				<td><a href="https://etherscan.io/tx/0x31f901eb28616fd083be65a1a9f6db1c0278ce52651f8bfe674776c97d0f812a" target="_blank">0x31f901eb2...</a></td>
                    				<td>1 Star</td>
						<td>01/04/2018 @11:29pm</td>
						<td>Active</td>
                			</tr>
            			</tbody>
        		</table>
    		</div>
            </div>

        </div>
    </div>
</div>
@endsection
