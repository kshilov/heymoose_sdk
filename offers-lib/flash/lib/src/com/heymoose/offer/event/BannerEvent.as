/**
 * Created by IntelliJ IDEA.
 * User: Sokolov Stanislav
 * Date: 12/7/11
 * Time: 8:42 PM
 */
package com.heymoose.offer.event
{
import flash.events.Event;

import mx.utils.ObjectUtil;

public class BannerEvent extends Event
{
	public static const SHOW:String = "com.heymoose.offer.event.show";
	public static const CLICK:String = "com.heymoose.offer.event.click";

	public var offer:Object;

	public function BannerEvent ( type:String, offer:Object, bubbles:Boolean = true )
	{
		this.offer = offer;
		trace ( offer.id, type );
		super ( type, bubbles )
	}
}
}
