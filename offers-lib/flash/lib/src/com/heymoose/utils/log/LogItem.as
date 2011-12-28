/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/28/11
 * Time: 12:10 PM
 */
package com.heymoose.utils.log
{
import com.heymoose.core.net.AsyncToken;

public class LogItem
{
	private var _startTime:int;
	public var time:int;
	public var request:String;
	public var method:String;
	public var result:String;
	public var fault:Boolean;
	public function LogItem (token:AsyncToken)
	{
	}

	public function set endTime ( value:int ):void
	{
		time = value - _startTime;
	}

	public function set startTime ( value:int ):void
	{
		_startTime = value;
	}
	public function toString():String
	{
		if(fault)
		{
			return "FAULT "+method + " ("+time.toString()+")";
		}
		else
		{
			return method + " ("+time.toString()+")";
		}

	}
}
}
