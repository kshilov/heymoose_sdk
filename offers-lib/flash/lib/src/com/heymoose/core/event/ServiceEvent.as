/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 1/24/12
 * Time: 12:03 PM
 */
package com.heymoose.core.event
{
import flash.events.Event;

public class ServiceEvent extends Event
{
	public var request:String;
	public var method:String;

	public static const REQUEST_SENT:String = "com.heymoose.core.event.requestSent";
	public static const REQUEST_COMPLETED:String = "com.heymoose.core.event.requestCompleted";
	public static const REQUEST_FAULT:String = "com.heymoose.core.event.requestFault";

	public function ServiceEvent ( type:String, method:String, request:String )
	{
		this.request = request;
		this.method = method;
		super ( type );
	}
}
}
